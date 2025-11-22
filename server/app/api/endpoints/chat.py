from http.client import HTTPException
import json
import uuid
from fastapi import FastAPI, Depends, BackgroundTasks, APIRouter,  HTTPException, status
from pydantic import BaseModel
import os

from sqlalchemy import select
from app.core.config import settings
from app.services.llm_service import LLMService
from typing import List, Dict, Optional, AsyncGenerator
from app.db.db_structure import Category, Conversation, GoalDraft, Message, ScheduleDraft, Task
from app.core.session import get_current_user
from app.db.db_structure import User
from datetime import datetime, date
import json
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.database import get_db
from app.api.models.conversation import ConversationResponse
from app.api.prompts import DEFAULT_TASK_PARSER_PROMPT, INTENT_PROMPT, SCHEDULE_SYSTEM_PROMPT, build_default_system_prompt, build_goal_analyzer_prompt

import re
from datetime import datetime, timedelta
import calendar
import pytz
from fastapi.responses import StreamingResponse
import asyncio

router = APIRouter()
app = FastAPI(title="Groq LLM API", version="1.0.0")


class ChatRequest(BaseModel):
    conversation_id: Optional[str] = None
    message: str
    # model: str = "llama-3.1-8b-instant"  # Default Groq model
    model: str = "gpt-4o-mini"
    # model: str = "openai/gpt-oss-120b"
    # system_prompt: Optional[str] = None  
    conversation_history: Optional[List[Dict[str, str]]] = []  
    mode: Optional[str] = None    #mode="generate_plan"

class ChatResponse(BaseModel):
    response: str
    usage: dict = {}
    model: str

class TaskIntentResponse(BaseModel):
    intent: str
    title: str
    description: str
    category_id: int
    date: datetime
    due_date: Optional[datetime] = None 
# Dependency để tạo LLM service
async def get_llm_service():
    llm_service = LLMService(
        # api_key=settings.CHAT_KEY,
        # base_url="https://api.groq.com/openai/v1"
        api_key=settings.OPENAI_API_KEY,
        base_url="https://api.openai.com/v1"
    )

    try:
        yield llm_service  
    finally:
        await llm_service.close()


@router.post("/chat/parse_task", response_model=List[TaskIntentResponse])
async def parse_task(
    req: ChatRequest,
    llm_service: LLMService = Depends(get_llm_service),
    current_user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db)
):
    try:
        system_prompt = DEFAULT_TASK_PARSER_PROMPT

        messages = [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": req.message}
        ]

        result = await llm_service.generate_response_with_messages(
            messages=messages,
            model=req.model
        )

        raw_response = result["response"].strip()

        # parse JSON
        parsed = json.loads(raw_response)

        # Nếu response là dict (1 task) → bọc lại thành list
        if isinstance(parsed, dict):
            parsed = [parsed]

        default_category = await session.scalar(
            select(Category).where(Category.owner_id == current_user.id, Category.is_default == True)
        )
        default_category_id = default_category.id if default_category else None

        category_id = task_data.get("category_id")
        if not category_id:
            category_id = default_category_id
        else:
            # Kiểm tra category đó có thuộc user hiện tại không
            check_category = await session.scalar(
                select(Category).where(Category.id == category_id, Category.owner_id == current_user.id)
            )
            if not check_category:
                category_id = default_category_id



        tasks: List[TaskIntentResponse] = []
        for task_data in parsed:
            intent = task_data.get("intent", "small_talk")
            title = task_data.get("title", "None Title")
            description = task_data.get("description", "")
            category_id = task_data.get("category_id", default_category_id)

            # xử lý date
            date_str = task_data.get("date")
            if date_str:
                try:
                    start_datetime = datetime.fromisoformat(date_str)
                except Exception:
                    start_datetime = datetime.now()
            else:
                start_datetime = datetime.now()

            # xử lý due_date
            due_date = None
            if task_data.get("due_date"):
                try:
                    due_date = datetime.fromisoformat(task_data["due_date"])
                except Exception:
                    due_date = None

            tasks.append(TaskIntentResponse(
                intent=intent,
                title=title,
                description=description,
                category_id=category_id,
                date=start_datetime,
                due_date=due_date
            ))

        return tasks

    except Exception as e:
        # fallback: return small_talk task
        now = datetime.now()
        return [
            TaskIntentResponse(
                intent="small_talk",
                title="",
                description="",
                category_id=1,
                date=now,
                due_date=None
            )
        ]
# @router.post("/chat/parse_task", response_model=List[TaskIntentResponse])
# async def parse_task(
#     req: ChatRequest,
#     llm_service: LLMService = Depends(get_llm_service),
#     current_user: User = Depends(get_current_user)
# ):
#     try:
#         system_prompt = """
#             You are a task parser assistant.
#             Extract structured task information from user messages.

#             Rules:
#             - If the input contains a schedule or a list of tasks with times, return an array of tasks (JSON list).
#             - If the user asks to create or schedule something, always return "intent": "create_task".
#             - If the user says anything with "task", "reminder", "schedule", "wake up", "meet", "plan", etc → always "create_task".
#             - If the user just chats, return "intent": "small_talk".
#             - If input is a schedule or a list of activities (e.g., "2:00 PM - 2:30 PM: Coding Project"), treat each entry as a task with "intent": "create_task".
#             - Always prefer "create_task" over "small_talk" if there are action items, times, or tasks mentioned.
#             - If no date/time is given, use the current datetime (YYYY-MM-DDTHH:MM:SS).
#             - "due_date" can be null.

#            Return ONLY valid JSON.
#             If multiple tasks exist, return an array of objects in this format:
#             [
#             {
#                 "intent": "create_task",
#                 "title": "...",
#                 "description": "...",
#                 "category_id": 57,
#                 "date": "YYYY-MM-DDTHH:MM:SS",
#                 "due_date": null
#             },
#             ...
#             ]
#             """


#         messages = [
#             {"role": "system", "content": system_prompt},
#             {"role": "user", "content": req.message}
#         ]

#         result = await llm_service.generate_response_with_messages(
#             messages=messages,
#             model=req.model
#         )

#         raw_response = result["response"].strip()
#         parsed = json.loads(raw_response)

#         parsed = json.loads(raw_response)

#         intent = parsed.get("intent", "small_talk")
#         title = parsed.get("title", "")

#         # nếu không có date/time thì dùng datetime.now()
#         date_str = parsed.get("date")
#         if date_str:
#             start_datetime = datetime.fromisoformat(date_str)
#         else:
#             start_datetime = datetime.now()


#         # nếu không có due_date thì để None
#         due_datetime = None
#         # if date_str and time_str:
#         #     due_datetime = start_datetime + timedelta(hours=1)

#         return TaskIntentResponse(
#             intent=intent,
#             title=title,
#             description=parsed.get("description", ""),  # default ""
#             category_id=parsed.get("category_id", 57),   # default category
#             date=start_datetime,
#             due_date=due_datetime
#         )

#     except Exception as e:
#         now = datetime.now()
#         return TaskIntentResponse(
#             intent="small_talk",
#             title="",
#             description="",
#             category_id=1,
#             date=now,
#             due_date=None   
#         )
#--------------Get all conversation--------------
@router.get("/conversations/", response_model=List[ConversationResponse])
async def get_all_conversations(
    current_user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db),
):
    # 🔹 Lấy tất cả cuộc trò chuyện của user hiện tại
    conversations = (await session.scalars(
        select(Conversation)
        .where(Conversation.user_id == current_user.id)
        .order_by(Conversation.updated_at.desc())  # sắp xếp theo thời gian gần nhất
    )).all()

    return conversations
#-------------Get message of the conversation-------
@router.get("/conversations/{conversation_id}/messages")
async def get_messages(
    conversation_id: str,
    session: AsyncSession = Depends(get_db),
    user=Depends(get_current_user)
):
    # --- 1️⃣ Kiểm tra conversation có tồn tại không ---
    result = await session.execute(
        select(Conversation).where(Conversation.id == str(conversation_id))
    )
    conversation = result.scalar_one_or_none()

    if not conversation:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Conversation not found"
        )

    # --- 2️⃣ Kiểm tra quyền truy cập ---
    if conversation.user_id != user.id:  # chỉ cho phép chủ sở hữu conversation
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You are not allowed to access this conversation"
        )

    # --- 3️⃣ Trả về messages ---
    result = await session.execute(
        select(Message)
        .where(Message.conversation_id == str(conversation_id))
        .order_by(Message.created_at)
    )
    messages = result.scalars().all()
    return messages

#--------------SEND MESSAGE----------------------
@router.post("/chat/", response_model=ChatResponse)
async def chat_endpoint(
    request: ChatRequest,
    llm_service: LLMService = Depends(get_llm_service),
    current_user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db),
):
    # ---------- 1. Classify intent ----------
    intent_messages = [
    {"role": "system", "content": INTENT_PROMPT.format(user_message=request.message)}
    ]

    intent_result = await llm_service.generate_response_with_messages(
        messages=intent_messages,
        # model="llama-3.1-8b-instant"
        model="gpt-4o-mini"
    )


    intent = intent_result["response"].strip().lower()
    print("RAW intent_result:", intent_result)

    # ---------- 2. Nếu intent = goal → dùng logic goal ----------
    # if intent == "goal":
    #     return await handle_goal_chat(
    #         req=request,
    #         llm_service=llm_service,
    #         current_user=current_user,
    #         session=session
    #     )

    # ---------- 3. Nếu small talk → xử lý chat bình thường ----------
    return await handle_small_talk_chat(
        request=request,
        llm_service=llm_service,
        current_user=current_user,
        session=session
    )
# ----------- handle small_talk--------------------
@router.post("/chat/small_talk", response_model=ChatResponse)
async def handle_small_talk_chat(
    request: ChatRequest,
    llm_service: LLMService = Depends(get_llm_service),
    current_user: User = Depends(get_current_user),
    # session: AsyncSession = Depends(get_async_session),
    session: AsyncSession = Depends(get_db),
):
    # 1️⃣ Lấy hoặc tạo mới conversation
    conversation = await session.scalar(
        select(Conversation).where(Conversation.id == request.conversation_id, Conversation.user_id == current_user.id )
    )
    # if not conversation:
    #     conversation = Conversation(user_id=current_user.id, title="New Chat")
    #     session.add(conversation)
    #     await session.flush()  # để có conversation.id
    if not conversation:
        conversation = Conversation(
            id=str(uuid.uuid4()),  
            user_id=current_user.id,
            title="New Chat",
            created_at=datetime.utcnow(),
            updated_at=datetime.utcnow()
        )
            
    session.add(conversation)
    await session.flush()


    # 2️⃣ Tạo danh sách messages (system + lịch sử từ DB + user message)
    messages = []

    # Thêm system prompt nếu có
    # messages.append({"role": "system", "content": DEFAULT_CHAT_PROMPT})
    messages.append({"role": "system", "content": build_default_system_prompt()})
    # Lấy lịch sử tin nhắn từ DB
    db_messages = (await session.scalars(
        select(Message)
        .where(Message.conversation_id == conversation.id)
        .order_by(Message.created_at)
    )).all()
    for msg in db_messages:
        messages.append({"role": msg.role, "content": msg.content})

    # Thêm tin nhắn user mới
    user_message = Message(
        conversation_id=conversation.id,
        role="user",
        content=request.message
    )
    session.add(user_message)
    messages.append({"role": "user", "content": request.message})

    # 3️⃣ Gọi LLM
    result = await llm_service.generate_response_with_messages(
        messages=messages,
        model=request.model
    )

    # 4️⃣ Lưu phản hồi của AI
    ai_message = Message(
        conversation_id=conversation.id,
        role="assistant",
        content=result["response"]
    )
    session.add(ai_message)
    await session.commit()

    # 5️⃣ Trả về response
    return ChatResponse(
        response=result["response"],
        usage=result["usage"],
        model=result["model"]
    )
# -------generate plan
@router.post("/chat/schedule", response_model=ChatResponse)
async def chat_schedule(
    req: ChatRequest,
    llm: LLMService = Depends(get_llm_service),
    current_user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db)
):
    # 1️⃣ Lấy hoặc tạo ScheduleDraft
    draft = await session.scalar(
        select(ScheduleDraft).where(ScheduleDraft.user_id == current_user.id)
    )

    if not draft:
        draft = ScheduleDraft(
            user_id=current_user.id,
            schedule_json={
                "schedule_title": None,
                "start_date": None,
                "end_date": None,
                "days": [],
                "fields_missing": [],
                "is_complete": False
            }
        )
        session.add(draft)
        await session.flush()

    # 2️⃣ Build messages cho LLM
    messages = [
        {"role": "system", "content": SCHEDULE_SYSTEM_PROMPT},
        {"role": "system", "content": f"Current schedule draft: {json.dumps(draft.schedule_json)}"},
        {"role": "system", "content": f"Mode: generate_plan"},  # Backend trigger
        {"role": "user", "content": req.message}
    ]

    # 3️⃣ Gọi LLM
    result = await llm.generate_response_with_messages(
        messages=messages,
        model=req.model
    )

    # 4️⃣ Parse JSON response
    try:
        parsed = json.loads(result["response"])
        ai_text = parsed["assistant_reply"]
        updated_draft = parsed["schedule_draft"]
    except:
        # fallback an toàn
        ai_text = result["response"]
        updated_draft = draft.schedule_json

    # 5️⃣ Lưu ngay vào DB
    draft.schedule_json = updated_draft
    draft.updated_at = datetime.utcnow()
    await session.commit()

    # 6️⃣ Trả về response
    return ChatResponse(
        response=ai_text,
        usage=result["usage"],
        model=result["model"],
        extra={"schedule_draft": updated_draft}
    )
# -------------------------
@router.post("/chat/create_tasks_from_schedule", response_model=ChatResponse)
async def create_tasks_from_schedule(draft: ScheduleDraft, session: AsyncSession, user_id: int):
    """
    Tạo task riêng trong DB từ một ScheduleDraft.
    
    Args:
        draft (ScheduleDraft): object ScheduleDraft đã lưu JSON.
        session (AsyncSession): session async của SQLAlchemy.
        user_id (int): id của user để gán vào Task.
    """
    tasks_created = []

    for day in draft.schedule_json.get("days", []):
        date_str = day.get("date")  # ví dụ "2023-10-01"
        for t in day.get("tasks", []):
            time_str = t.get("time", "00:00")  # ví dụ "07:00"
            datetime_str = f"{date_str} {time_str}"
            
            try:
                start_dt = datetime.strptime(datetime_str, "%Y-%m-%d %H:%M")
            except ValueError:
                # fallback: nếu format sai thì chỉ lấy date + 00:00
                start_dt = datetime.strptime(date_str, "%Y-%m-%d")

            task = Task(
                user_id=user_id,
                title=t.get("description", ""),
                start_time=start_dt,
                duration=t.get("length", ""),  # có thể parse thêm nếu muốn timedelta
                schedule_draft_id=draft.id
            )
            session.add(task)
            tasks_created.append(task)

    await session.commit()
    return tasks_created
# ----- endpoint test lưu mock schedule draft -----
@router.post("/chat/schedule/mock", response_model=ChatResponse)
async def chat_schedule_mock(
    current_user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db),
):
    # Paste mock response JSON từ LLM
    mock_response = {
        "assistant_reply": "I've created a structured plan to help you lose 2 kg. This includes workouts, meal planning, and tracking your progress. Here's the schedule:",
        "schedule_draft": {
            "days": [
                {
                    "date": "2025-12-01",
                    "tasks": [
                        {"time": "07:00", "length": "30 minutes", "description": "Morning jog or brisk walk"},
                        {"time": "08:00", "length": "30 minutes", "description": "Prepare and eat a healthy breakfast (e.g., oatmeal with fruits)"}
                    ]
                },
                {
                    "date": "2023-10-02",
                    "tasks": [
                        {"time": "07:00", "length": "30 minutes", "description": "HIIT workout (high-intensity interval training)"},
                        {"time": "08:00", "length": "30 minutes", "description": "Healthy breakfast (smoothie with spinach and protein)"}
                    ]
                }
            ],
            "start_date": "2023-10-01",
            "end_date": "2023-10-03",
            "is_complete": False,
            "fields_missing": [],
            "schedule_title": "Weight Loss Plan - 2 kg Target"
        }
    }

    # 1️⃣ Lấy hoặc tạo ScheduleDraft
    draft = await session.scalar(
        select(ScheduleDraft).where(ScheduleDraft.user_id == current_user.id)
    )
    if not draft:
        draft = ScheduleDraft(
            user_id=current_user.id,
            schedule_json={}
        )
        session.add(draft)
        await session.flush()

    # 2️⃣ Lưu thẳng vào DB
    draft.schedule_json = mock_response["schedule_draft"]
    draft.updated_at = datetime.utcnow()
    await session.commit()

    return ChatResponse(
        response=mock_response["assistant_reply"],
        usage={},
        model="mock",
        extra={"schedule_draft": mock_response["schedule_draft"]}
    )

# @router.post("/chat/schedule", response_model=ChatResponse)
# async def chat_schedule(
#     req: ChatRequest,
#     llm: LLMService = Depends(get_llm_service),
#     current_user: User = Depends(get_current_user),
#     session: AsyncSession = Depends(get_db)
# ):
#     # ------------------------------
#     # 1) Lấy hoặc tạo ScheduleDraft
#     # ------------------------------
#     draft = await session.scalar(
#         select(ScheduleDraft).where(ScheduleDraft.user_id == current_user.id)
#     )

#     if not draft:
#         draft = ScheduleDraft(
#             user_id=current_user.id,
#             schedule_json={
#                 "schedule_title": None,
#                 "start_date": None,
#                 "end_date": None,
#                 "days": [],
#                 "fields_missing": [],
#                 "is_complete": False
#             }
#         )
#         session.add(draft)
#         await session.flush()

#     # ------------------------------
#     # 2) Build messages cho LLM
#     # ------------------------------
#     messages = [
#         {"role": "system", "content": SCHEDULE_SYSTEM_PROMPT},
#         {"role": "system", "content": f"Current schedule draft: {json.dumps(draft.schedule_json)}"},
#         {"role": "system", "content": f"Mode: {req.mode}"},
#         {"role": "user", "content": req.message}
#     ]

#     # ------------------------------
#     # 3) Gọi LLM
#     # ------------------------------
#     result = await llm.generate_response_with_messages(
#         messages=messages,
#         model=req.model
#     )

#     print("LLM RESULT:", result)

#     # ------------------------------
#     # 4) Parse JSON response
#     # ------------------------------
#     try:
#         parsed = json.loads(result["response"])
#         ai_text = parsed["assistant_reply"]
#         updated_draft = parsed["schedule_draft"]
#     except:
#         # fallback an toàn
#         ai_text = result["response"]
#         updated_draft = draft.schedule_json

#     # ------------------------------
#     # 5) Lưu vào DB
#     # ------------------------------
#     draft.schedule_json = updated_draft
#     draft.updated_at = datetime.utcnow()

#     await session.commit()

#     # ------------------------------
#     # 6) Trả kết quả
#     # ------------------------------
#     return ChatResponse(
#         response=ai_text,
#         usage=result["usage"],
#         model=result["model"],
#         extra={"schedule_draft": updated_draft}
#     )


# ------handle date data -------------
def parse_human_date(text: str):
    """
    Parse human-readable date strings to datetime object with timestamp
    Returns: datetime object (e.g., 2025-11-20 00:00:00) or None
    """
    if not text:
        return None
        
    text = text.lower().strip()
    
    # ✅ Dùng pytz để lấy thời gian VN
    tz = pytz.timezone('Asia/Ho_Chi_Minh')
    now = datetime.now(tz)
    
    print(f"[parse_human_date] Input: '{text}', Now: {now}")

    # --------- Remove extra words ---------
    text = text.replace("'s date", "").replace(" date", "").replace("'s", "")
    text = text.strip()
    print(f"[parse_human_date] After cleanup: '{text}'")

    # --------- Direct keywords ---------
    if text == "today":
        return now.replace(hour=0, minute=0, second=0, microsecond=0)

    if text == "tomorrow":
        return (now + timedelta(days=1)).replace(hour=0, minute=0, second=0, microsecond=0)

    if text == "yesterday":
        return (now - timedelta(days=1)).replace(hour=0, minute=0, second=0, microsecond=0)

    # --------- "In X days/weeks/months" ---------
    match = re.match(r"in (\d+) (day|days)", text)
    if match:
        n = int(match.group(1))
        return (now + timedelta(days=n)).replace(hour=0, minute=0, second=0, microsecond=0)

    match = re.match(r"in (\d+) (week|weeks)", text)
    if match:
        n = int(match.group(1))
        return (now + timedelta(weeks=n)).replace(hour=0, minute=0, second=0, microsecond=0)

    match = re.match(r"in (\d+) (month|months)", text)
    if match:
        n = int(match.group(1))
        month = now.month - 1 + n
        year = now.year + month // 12
        month = month % 12 + 1
        day = min(now.day, calendar.monthrange(year, month)[1])
        return datetime(year, month, day, 0, 0, 0, tzinfo=tz)

    # --------- "X days/weeks/months from now" ---------
    match = re.match(r"(\d+) (day|days) from now", text)
    if match:
        n = int(match.group(1))
        return (now + timedelta(days=n)).replace(hour=0, minute=0, second=0, microsecond=0)

    match = re.match(r"(\d+) (week|weeks) from now", text)
    if match:
        n = int(match.group(1))
        return (now + timedelta(weeks=n)).replace(hour=0, minute=0, second=0, microsecond=0)

    match = re.match(r"(\d+) (month|months) from now", text)
    if match:
        n = int(match.group(1))
        month = now.month - 1 + n
        year = now.year + month // 12
        month = month % 12 + 1
        day = min(now.day, calendar.monthrange(year, month)[1])
        return datetime(year, month, day, 0, 0, 0, tzinfo=tz)

    # --------- "X days/weeks/months from [target_date]" ---------
    match = re.match(r"(\d+) (day|days|week|weeks|month|months) from (.*)", text)
    if match:
        amount = int(match.group(1))
        unit = match.group(2).rstrip('s')
        target_str = match.group(3).strip()
        
        target_date = parse_human_date(target_str)
        if target_date:
            if unit == "day":
                return target_date + timedelta(days=amount)
            elif unit == "week":
                return target_date + timedelta(weeks=amount)
            elif unit == "month":
                month = target_date.month - 1 + amount
                year = target_date.year + month // 12
                month = month % 12 + 1
                day = min(target_date.day, calendar.monthrange(year, month)[1])
                return datetime(year, month, day, 0, 0, 0, tzinfo=tz)

    # --------- Next/This weekday ---------
    weekdays = {
        "monday": 0, "tuesday": 1, "wednesday": 2,
        "thursday": 3, "friday": 4, "saturday": 5, "sunday": 6
    }

    match = re.match(r"next (monday|tuesday|wednesday|thursday|friday|saturday|sunday)", text)
    if match:
        target = weekdays[match.group(1)]
        days_ahead = (target - now.weekday() + 7) % 7
        days_ahead = 7 if days_ahead == 0 else days_ahead
        return (now + timedelta(days=days_ahead)).replace(hour=0, minute=0, second=0, microsecond=0)

    match = re.match(r"this (monday|tuesday|wednesday|thursday|friday|saturday|sunday)", text)
    if match:
        target = weekdays[match.group(1)]
        days_ahead = target - now.weekday()
        return (now + timedelta(days=days_ahead)).replace(hour=0, minute=0, second=0, microsecond=0)

    # --------- Next week/month ---------
    if text == "next week":
        return (now + timedelta(weeks=1)).replace(hour=0, minute=0, second=0, microsecond=0)

    if text == "next month":
        month = now.month % 12 + 1
        year = now.year + (now.month // 12)
        day = min(now.day, calendar.monthrange(year, month)[1])
        return datetime(year, month, day, 0, 0, 0, tzinfo=tz)

    # --------- ISO format YYYY-MM-DD ---------
    try:
        parsed = datetime.fromisoformat(text)
        if parsed.tzinfo is None:
            parsed = tz.localize(parsed)
        print(f"[parse_human_date] Parsed ISO: {parsed}")
        return parsed.replace(hour=0, minute=0, second=0, microsecond=0)
    except:
        pass

    # --------- VN format DD/MM/YYYY ---------
    try:
        parsed = datetime.strptime(text, "%d/%m/%Y")
        parsed = tz.localize(parsed)
        print(f"[parse_human_date] Parsed VN format: {parsed}")
        return parsed
    except:
        pass

    print(f"[parse_human_date] ❌ Could not parse: '{text}'")
    return None

































# ------------handle goal chat - to collect necessarry details related goal ---------
@router.post("/chat/goal", response_model=ChatResponse)
async def handle_goal_chat(
    req: ChatRequest,
    llm_service: LLMService = Depends(get_llm_service),
    current_user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db)
):
    # ============================================
    # 1) LẤY HOẶC TẠO CONVERSATION
    # ============================================
    conversation = await session.scalar(
        select(Conversation)
        .where(Conversation.id == req.conversation_id,
               Conversation.user_id == current_user.id)
    )

    if not conversation:
        conversation = Conversation(
            id=str(uuid.uuid4()),
            user_id=current_user.id,
            title="Goal Chat",
            created_at=datetime.utcnow(),
            updated_at=datetime.utcnow(),
        )
        session.add(conversation)
        await session.flush()

    # ============================================
    # 2) LẤY HOẶC TẠO GOALDRAFT
    # ============================================
    draft = await session.scalar(
        select(GoalDraft)
        .where(GoalDraft.user_id == current_user.id,
               GoalDraft.status == "collecting")
    )

    if not draft:
        draft = GoalDraft(
            id=str(uuid.uuid4()),
            user_id=current_user.id,
            goal_title=None,
            measurable_target=None,
            daily_action=None,
            start_date=None,
            duration=None,
            end_date=None,
            status="collecting",
        )
        draft.fields_missing = [
            "goal_title", "measurable_target", "daily_action",
            "start_date", "duration", "end_date"
        ]
        session.add(draft)
        await session.flush()

    # ============================================
    # 3) BUILD MESSAGE HISTORY
    # ============================================
    messages = [{"role": "system", "content": build_goal_analyzer_prompt()}]

    db_messages = (
        await session.scalars(
            select(Message)
            .where(Message.conversation_id == conversation.id)
            .order_by(Message.created_at)
        )
    ).all()

    for msg in db_messages:
        messages.append({"role": msg.role, "content": msg.content})

    messages.append({"role": "user", "content": req.message})

    # Lưu user message
    session.add(Message(
        conversation_id=conversation.id,
        role="user",
        content=req.message,
    ))

    # ============================================
    # 4) CALL LLM
    # ============================================
    result = await llm_service.generate_response_with_messages(
        messages=messages,
        model=req.model
    )

    llm_text = result["response"]
    print(f"LLM Response:\n{llm_text}\n")

    # Lưu AI message
    session.add(Message(
        conversation_id=conversation.id,
        role="assistant",
        content=llm_text
    ))
    await session.commit()

    # ============================================
    # 5) PARSE JSON AN TOÀN
    # ============================================
    import re
    parsed = {"intent": "small_talk", "fields_missing": []}
    json_match = re.search(r"\{[\s\S]*\}", llm_text)

    if json_match:
        try:
            parsed = json.loads(json_match.group(0))
        except Exception as e:
            print("⚠ JSON parse failed:", e)

    print("Parsed JSON →", parsed)

    # ============================================
    # 5.1) TỰ ĐOÁN INTENT DỰA TRÊN DB
    # Nếu tất cả fields đã có giá trị → intent = create_goal
    # ============================================
    safe_fields = [
        "goal_title", "measurable_target", "daily_action",
        "start_date", "duration", "end_date",
    ]
    all_filled = all(getattr(draft, f) not in [None, ""] for f in safe_fields)
    if all_filled:
        parsed["intent"] = "create_goal"

    intent = parsed.get("intent")

    # ============================================
    # 6) Nếu không phải create_goal → chỉ hiển thị message thân thiện
    # ============================================
    if intent != "create_goal":
        follow_msg = "✨ " + parsed.get("message", llm_text)
        return ChatResponse(
            response=follow_msg,
            usage=result.get("usage"),
            model=result.get("model")
        )

    # ============================================
    # 7) CẬP NHẬT DRAFT
    # ============================================
    for field in safe_fields:
        val = parsed.get(field)
        if not val:
            continue

        # parse date nếu cần
        if field in ["start_date", "end_date"] and isinstance(val, str):
            d = parse_human_date(val)
            if d:
                setattr(draft, field, d)
                print(f"✔ {field} = {d}")
            continue

        setattr(draft, field, val)
        print(f"✔ {field} = {val}")

    # Recalculate missing
    draft.fields_missing = [
        f for f in safe_fields
        if getattr(draft, f) in [None, ""]
    ]

    # Nếu có duration → bỏ end_date khỏi missing
    if draft.duration and "end_date" in draft.fields_missing:
        draft.fields_missing.remove("end_date")

    await session.commit()
    print("Updated draft →", draft.fields_missing)

    # ============================================
    # 8) HỎI TIẾP NẾU CÒN FIELD THIẾU
    # ============================================
    if draft.fields_missing:
        QUESTIONS = {
            "goal_title": "What's the title of your goal?",
            "measurable_target": "What's the specific result you want to achieve?",
            "daily_action": "What will you do daily to reach it?",
            "start_date": "When do you want to start?",
            "duration": "How long do you want this goal to take?",
            "end_date": "When do you want to finish?"
        }

        follow_up = [QUESTIONS[f] for f in draft.fields_missing]
        follow_msg = "✨ Let's complete your goal:\n" + "\n".join(follow_up)

        return ChatResponse(
            response=follow_msg,
            usage=result.get("usage"),
            model=result.get("model")
        )

    # ============================================
    # 9) ĐỦ FIELD → GENERATE PLAN
    # ============================================
    plan = await generate_plan(draft)

    for item in plan:
        session.add(Task(
            goal_id=draft.id,
            title=item["title"],
            description=item["description"],
            due_date=item["due_date"],
        ))

    await session.commit()

    plan_text = "\n".join([f"{p['due_date']}: {p['title']} – {p['description']}" for p in plan])

    return ChatResponse(
        response=f"✅ Your 5-day plan is ready:\n{plan_text}",
        usage=result.get("usage"),
        model=result.get("model")
    )

# @router.post("/chat/goal", response_model=ChatResponse)
# async def handle_goal_chat(
#     req: ChatRequest,
#     llm_service: LLMService = Depends(get_llm_service),
#     current_user: User = Depends(get_current_user),
#     session: AsyncSession = Depends(get_db)
# ):
#     # ============================================
#     # 1) LẤY HOẶC TẠO CONVERSATION
#     # ============================================
#     conversation = await session.scalar(
#         select(Conversation)
#         .where(Conversation.id == req.conversation_id,
#                Conversation.user_id == current_user.id)
#     )

#     if not conversation:
#         conversation = Conversation(
#             id=str(uuid.uuid4()),
#             user_id=current_user.id,
#             title="Goal Chat",
#             created_at=datetime.utcnow(),
#             updated_at=datetime.utcnow(),
#         )
#         session.add(conversation)
#         await session.flush()

#     # ============================================
#     # 2) LẤY HOẶC TẠO GOALDRAFT
#     # ============================================
#     draft = await session.scalar(
#         select(GoalDraft)
#         .where(GoalDraft.user_id == current_user.id,
#                GoalDraft.status == "collecting")
#         # .order_by(GoalDraft.created_at.desc())
#     )

#     if not draft:
#         draft = GoalDraft(
#             id=str(uuid.uuid4()),
#             user_id=current_user.id,
#             goal_title=None,
#             measurable_target=None,
#             daily_action=None,
#             start_date=None,
#             duration=None,
#             end_date=None,
#             status="collecting",
#         )
#         draft.fields_missing = [
#             "goal_title", "measurable_target", "daily_action",
#             "start_date", "duration", "end_date"
#         ]
#         session.add(draft)
#         await session.flush()

#     # ============================================
#     # 3) BUILD MESSAGE HISTORY
#     # ============================================
#     # messages = [{"role": "system", "content": GOAL_ANALYZER_PROMPT}]
#     messages = [{"role": "system", "content": build_goal_analyzer_prompt()}]

#     db_messages = (
#         await session.scalars(
#             select(Message)
#             .where(Message.conversation_id == conversation.id)
#             .order_by(Message.created_at)
#         )
#     ).all()

#     for msg in db_messages:
#         messages.append({"role": msg.role, "content": msg.content})

#     messages.append({"role": "user", "content": req.message})

#     # Lưu user message
#     session.add(Message(
#         conversation_id=conversation.id,
#         role="user",
#         content=req.message,
#     ))

#     # ============================================
#     # 4) CALL LLM
#     # ============================================
#     result = await llm_service.generate_response_with_messages(
#         messages=messages,
#         model=req.model
#     )

#     llm_text = result["response"]
#     print(f"LLM Response:\n{llm_text}\n")

#     # Lưu AI message
#     session.add(Message(
#         conversation_id=conversation.id,
#         role="assistant",
#         content=llm_text
#     ))
#     await session.commit()

#     # ============================================
#     # 5) PARSE JSON — AN TOÀN 100%
#     #    TÌM JSON BẰNG REGEX KIỂU {"intent": ...}
#     # ============================================
#     import re
#     json_match = re.search(r"\{[\s\S]*\}", llm_text)

#     parsed = {"intent": "small_talk", "fields_missing": []}

#     if json_match:
#         try:
#             parsed = json.loads(json_match.group(0))
#         except Exception as e:
#             print("⚠ JSON parse failed:", e)

#     print("Parsed JSON →", parsed)

#     if not draft.fields_missing:
#         parsed["intent"] = "create_goal"

#     intent = parsed.get("intent")

#     # Nếu không phải intent create_goal → trả lời small talk luôn
#     if intent != "create_goal":
#         return ChatResponse(
#             response=llm_text,
#             usage=result.get("usage"),
#             model=result.get("model")
#         )

#     # ============================================
#     # 6) PHÁT HIỆN NEW GOAL (goal_title thay đổi)
#     # ============================================
#     new_title = parsed.get("goal_title")

#     if new_title:
#         if draft.goal_title and new_title.strip().lower() != draft.goal_title.strip().lower():
#             print("⚠ NEW GOAL → Abandon old draft.")

#             draft.status = "abandoned"
#             await session.commit()

#             draft = GoalDraft(
#                 id=str(uuid.uuid4()),
#                 user_id=current_user.id,
#                 status="collecting"
#             )
#             draft.fields_missing = [
#                 "goal_title", "measurable_target", "daily_action",
#                 "start_date", "duration", "end_date"
#             ]
#             session.add(draft)
#             await session.commit()

#     # ============================================
#     # 7) UPDATE DRAFT — CHỐNG LỖI TUYỆT ĐỐI
#     # ============================================
#     safe_fields = [
#         "goal_title", "measurable_target", "daily_action",
#         "start_date", "duration", "end_date",
#     ]

#     for field in safe_fields:
#         val = parsed.get(field)
#         if not val:
#             continue

#         # ----- parse date -----
#         if field in ["start_date", "end_date"] and isinstance(val, str):
#             d = parse_human_date(val)
#             if d:
#                 setattr(draft, field, d)
#                 print(f"✔ {field} = {d}")
#             continue

#         setattr(draft, field, val)
#         print(f"✔ {field} = {val}")

#     # Recalculate missing
#     required = safe_fields.copy()

#     draft.fields_missing = [
#         f for f in required
#         if getattr(draft, f) in [None, ""]
#     ]

#     # Nếu có duration → bỏ end_date
#     if draft.duration and "end_date" in draft.fields_missing:
#         draft.fields_missing.remove("end_date")

#     await session.commit()

#     print("Updated draft →", draft.fields_missing)

#     # ============================================
#     # 8) CHƯA ĐỦ FIELD → HỎI TIẾP
#     # ============================================
#     if draft.fields_missing:
#         QUESTIONS = {
#             "goal_title": "What's the title of your goal?",
#             "measurable_target": "What's the specific result you want to achieve?",
#             "daily_action": "What will you do daily to reach it?",
#             "start_date": "When do you want to start?",
#             "duration": "How long do you want this goal to take?",
#             "end_date": "When do you want to finish?"
#         }

#         follow_up = [QUESTIONS[f] for f in draft.fields_missing]
#         follow_msg = "✨ Let's complete your goal:\n" + "\n".join(follow_up)

#         return ChatResponse(
#             response=follow_msg,
#             usage=result.get("usage"),
#             model=result.get("model")
#         )

#     # ============================================
#     # 9) ĐỦ FIELD → GENERATE PLAN
#     # ============================================
#     plan = await generate_plan(draft)

#     for item in plan:
#         session.add(Task(
#             goal_id=draft.id,
#             title=item["title"],
#             description=item["description"],
#             due_date=item["due_date"],
#         ))

#     await session.commit()

#     plan_text = "\n".join([
#         f"{p['due_date']}: {p['title']} – {p['description']}" for p in plan
#     ])

#     return ChatResponse(
#         response=f"✅ Your 5-day plan is ready:\n{plan_text}",
#         usage=result.get("usage"),
#         model=result.get("model")
#     )

# -------generate plan after collect all fiels of GoalDraft-----------
async def generate_plan(draft: GoalDraft):
    """
    Generate a detailed 3-5 day plan for a goal.
    Returns a list of dicts: [{title, description, due_date}, ...]
    """
    # 1️⃣ Số ngày để generate plan
    total_days = 5
    if draft.duration:
        try:
            # Nếu duration = "1 month", "2 weeks", convert sang số ngày
            # Đây là 1 ví dụ đơn giản, bạn có thể dùng dateparser/parse_human_date
            if "week" in draft.duration:
                total_days = min(5, int(draft.duration.split()[0]) * 7)
            elif "month" in draft.duration:
                total_days = min(5, int(draft.duration.split()[0]) * 30)
            else:
                total_days = min(5, int(draft.duration.split()[0]))
        except Exception:
            pass  # fallback = 5

    start_date = draft.start_date or datetime.utcnow().date()
    plan = []

    # 2️⃣ Chia measurable_target thành từng phần nhỏ
    target = draft.measurable_target or "Work on your goal"
    per_day_target = f"{target} - day"

    for i in range(total_days):
        day_task = {
            "title": f"{draft.goal_title} - Day {i+1}",
            "description": f"{draft.daily_action or 'Work on your goal'} ({per_day_target} {i+1})",
            "due_date": start_date + timedelta(days=i)
        }
        plan.append(day_task)

    return plan
