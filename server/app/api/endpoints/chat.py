from http.client import HTTPException
import json
import uuid
from fastapi import FastAPI, Depends, APIRouter,  HTTPException, status
from pydantic import BaseModel
import os

from sqlalchemy import select
from app.core.config import settings
from app.services.llm_service import LLMService
from typing import List, Dict, Optional, Any
from app.db.db_structure import Category, Conversation, Message, ScheduleDraft, ScheduleDraftInput, Task
from app.core.session import get_current_user
from app.db.db_structure import User
from datetime import datetime
import json
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.database import get_db
from app.api.models.conversation import ConversationResponse
from app.api.prompts import DEFAULT_TASK_PARSER_PROMPT, INTENT_PROMPT, SCHEDULE_SYSTEM_PROMPT, SMALL_TALK_SYSTEM_PROMPT, VN_TZ, build_default_system_prompt
import re
from datetime import datetime, timedelta
import calendar
import pytz

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
    extra: Optional[Dict[str, Any]] = None
    conversation_id: Optional[str] = None

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
@router.post("/conversations/", response_model=ConversationResponse)
async def create_conversation(
    session: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    # 1️⃣ Tạo conversation
    conversation = Conversation(
        id=str(uuid.uuid4()),
        user_id=current_user.id,
        title="New Chat",
        created_at=datetime.utcnow(),
        updated_at=datetime.utcnow(),
    )
    session.add(conversation)
    await session.flush()  # đảm bảo conversation.id tồn tại

    # 2️⃣ Tạo schedule draft tương ứng (1–1)
    schedule_draft = ScheduleDraft(
        user_id=current_user.id,
        conversation_id=conversation.id,
        schedule_json={}
    )
    session.add(schedule_draft)

    # 3️⃣ Commit
    await session.commit()

    return conversation

#--------------SEND MESSAGE----------------------
@router.post("/chat/", response_model=ChatResponse)
async def chat_endpoint(
    request: ChatRequest,
    llm_service: LLMService = Depends(get_llm_service),
    current_user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db),
):
    # ---------- 1. Classify intent ----------
    # intent_messages = [
    # {"role": "system", "content": INTENT_PROMPT.format(user_message=request.message)}
    # ]

    # intent_result = await llm_service.generate_response_with_messages(
    #     messages=intent_messages,
    #     # model="llama-3.1-8b-instant"
    #     model="gpt-4o-mini"
    # )


    # intent = intent_result["response"].strip().lower()
    # print("RAW intent_result:", intent_result)

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
        select(Conversation).where(
            Conversation.id == request.conversation_id, 
            Conversation.user_id == current_user.id
        )
    )
    
    if not conversation:
        # Dùng ID từ request nếu có, nếu không thì tạo mới
        conversation_id = request.conversation_id if request.conversation_id else str(uuid.uuid4())
        
        conversation = Conversation(
            id=conversation_id,  # ✅ Dùng ID từ request hoặc tạo mới
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
    messages.append({"role": "system", "content": SMALL_TALK_SYSTEM_PROMPT})
    # Lấy lịch sử tin nhắn từ DB
    # db_messages = (await session.scalars(
    #     select(Message)
    #     .where(Message.conversation_id == conversation.id)
    #     .order_by(Message.created_at)
    # )).all()
    db_messages = (await session.scalars(
    select(Message)
    .where(Message.conversation_id == conversation.id)
    .order_by(Message.created_at.desc())
    .limit(8)
    )).all()
    for msg in reversed(db_messages):
        messages.append({"role": msg.role, "content": msg.content})
    # for msg in db_messages:
    #     messages.append({"role": msg.role, "content": msg.content})

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
        model=result["model"],
        conversation_id=conversation.id 
    )

# -------generate plan
@router.post("/chat/schedule", response_model=ChatResponse)
async def chat_schedule(
    req: ChatRequest,
    llm: LLMService = Depends(get_llm_service),
    current_user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db)
):
    # ✅ Lấy thời gian HIỆN TẠI ngay đầu
    now_vn = datetime.now(VN_TZ)
    current_datetime_iso = now_vn.isoformat()
    current_date_str = now_vn.strftime("%Y-%m-%d")
    current_time_str = now_vn.strftime("%H:%M")
    
    # # 0️⃣ Lấy hoặc tạo conversation
    # conversation = await session.scalar(
    #     select(Conversation).where(
    #         Conversation.user_id == current_user.id,
    #         Conversation.id == req.conversation_id
    #     )
    # )

    # if not conversation:
    #     conversation = Conversation(
    #         id=str(uuid.uuid4()),
    #         user_id=current_user.id,
    #         title="Schedule Chat",
    #         created_at=datetime.utcnow(),
    #         updated_at=datetime.utcnow()
    #     )
    #     session.add(conversation)
    #     await session.flush()
      # 0️⃣ Lấy hoặc tạo conversation
    conversation = await session.scalar(
        select(Conversation).where(
            Conversation.user_id == current_user.id,
            Conversation.id == req.conversation_id
        )
    )

    if not conversation:
        # ✅ SỬA: Dùng ID từ request nếu có
        conversation_id = req.conversation_id if req.conversation_id else str(uuid.uuid4())
        
        conversation = Conversation(
            id=conversation_id,  # ✅ Dùng ID từ request hoặc tạo mới
            user_id=current_user.id,
            title="Schedule Chat",
            created_at=datetime.utcnow(),
            updated_at=datetime.utcnow()
        )
        session.add(conversation)
        await session.flush()

    # 1️⃣ Lấy hoặc tạo ScheduleDraft
    draft = await session.scalar(
        select(ScheduleDraft).where(
            ScheduleDraft.user_id == current_user.id,
            ScheduleDraft.conversation_id == conversation.id
        )
    )

    if not draft:
        draft = ScheduleDraft(
            user_id=current_user.id,
            conversation_id=conversation.id, 
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

    # ✅ 1.5️⃣ Lưu user message vào DB
    user_message = Message(
        conversation_id=conversation.id,
        role="user",
        content=req.message,
        created_at=datetime.utcnow()
    )
    session.add(user_message)
    await session.flush()
 
    # 2️⃣ Build messages cho LLM
    messages = [
        {"role": "system", "content": f"You are Lumiere assistant. Current time: {current_datetime_iso}. Use this for all reasoning."},
        {"role": "system", "content": SCHEDULE_SYSTEM_PROMPT},
        {
            "role": "system", 
            "content": f"TODAY: {current_date_str} at {current_time_str}. Schedule from NOW onwards. Draft: {json.dumps(draft.schedule_json)}"
        },
        {"role": "user", "content": req.message}
    ]


    # 3️⃣ Gọi LLM
    result = await llm.generate_response_with_messages(
        messages=messages,
        model=req.model
    )

    # 4️⃣ Parse JSON response - ✅ CHUẨN HÓA FORMAT
    ai_text = ""
    updated_draft = {}
    
    try:
        parsed = json.loads(result["response"])
        
        # ✅ Trích xuất ai_text
        if "assistant_reply" in parsed:
            ai_text = parsed["assistant_reply"]
        else:
            ai_text = "Here's your schedule."
        
        # ✅ Trích xuất schedule_draft
        if "schedule_draft" in parsed:
            # Format cũ: {"assistant_reply": "...", "schedule_draft": {...}}
            raw_draft = parsed["schedule_draft"]
        elif "days" in parsed:
            # Format mới: {"days": [...]}
            raw_draft = parsed
        else:
            # Không có schedule → giữ nguyên draft cũ
            raw_draft = draft.schedule_json
        
        # ✅ Chuẩn hóa thành format CHUẨN
        updated_draft = {
            "schedule_title": raw_draft.get("schedule_title", None),
            "start_date": raw_draft.get("start_date", None),
            "end_date": raw_draft.get("end_date", None),
            "days": raw_draft.get("days", []),
            "fields_missing": raw_draft.get("fields_missing", []),
            "is_complete": raw_draft.get("is_complete", False)
        }
        
        # ✅ Tự động điền start_date/end_date từ days
        if updated_draft["days"] and len(updated_draft["days"]) > 0:
            if not updated_draft["start_date"]:
                updated_draft["start_date"] = updated_draft["days"][0].get("date")
            if not updated_draft["end_date"]:
                updated_draft["end_date"] = updated_draft["days"][0].get("date")
        
        # ✅ ĐẢM BẢO schedule_title LUÔN CÓ GIÁ TRỊ
        if not updated_draft["schedule_title"]:
            updated_draft["schedule_title"] = "My Schedule"
        
        # ✅ Validate days structure
        validated_days = []
        for day_item in updated_draft["days"]:
            if isinstance(day_item, dict) and "date" in day_item and "tasks" in day_item:
                validated_days.append({
                    "date": day_item["date"],
                    "tasks": [
                        {
                            "time": task.get("time", ""),
                            "length": task.get("length", ""),
                            "description": task.get("description", "")
                        }
                        for task in day_item.get("tasks", [])
                        if isinstance(task, dict)
                    ]
                })
        updated_draft["days"] = validated_days
        
        print(f"✅ Parsed schedule successfully: {len(validated_days)} days")
        print(f"📝 Final draft structure: {json.dumps(updated_draft, indent=2)}")

    except json.JSONDecodeError as e:
        print(f"❌ JSON decode error: {e}")
        ai_text = result["response"]  # Text thuần
        updated_draft = draft.schedule_json  # Giữ nguyên draft cũ
    
    except Exception as e:
        print(f"❌ Error processing schedule: {e}")
        ai_text = result["response"] if isinstance(result["response"], str) else "Error processing schedule"
        updated_draft = draft.schedule_json

    # 5️⃣ Lưu ScheduleDraft
    draft.schedule_json = updated_draft
    draft.updated_at = datetime.utcnow()
    await session.flush()

    # 6️⃣ Lưu message assistant với conversation_id
    assistant_message = Message(
        conversation_id=conversation.id,
        role="assistant",
        content=ai_text,  # ✅ Lưu text, không lưu JSON
        custom_properties={"schedule_draft": updated_draft},  # ✅ Lưu schedule ở đây
        created_at=datetime.utcnow()
    )
    session.add(assistant_message)
    await session.commit()

    # 7️⃣ Trả về response
    print(f"🔍 Response extra: {json.dumps({'schedule_draft': updated_draft}, indent=2)}")
    
    return ChatResponse(
        response=ai_text,  # ✅ Text để hiển thị
        usage=result["usage"],
        model=result["model"],
        extra={"schedule_draft": updated_draft, "conversation_id": conversation.id}
    )

# -------------------------create tasks from schedule----------------
@router.post("/chat/create_tasks_from_schedule", response_model=ChatResponse)
async def create_tasks_from_schedule(
    draft: ScheduleDraftInput,
    # category_id: Optional[int] = None,  # ✅ Thêm parameter
    session: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    tasks_created = []
    
    # ✅ Sử dụng category_id được truyền vào, nếu không có thì dùng default
    # target_category_id = category_id if category_id else 94
    target_category_id = draft.category_id
    for day in draft.schedule_json.get("days", []):
        for t in day.get("tasks", []):
            date_str = t.get("date")
            due_date_str = t.get("due_date")
            
            try:
                start_dt = datetime.fromisoformat(date_str)
                due_dt = datetime.fromisoformat(due_date_str) if due_date_str else None
            except (ValueError, TypeError):
                continue
            
            task = Task(
                owner_id=current_user.id,
                category_id=target_category_id,  # ✅ Dùng category_id động
                title=t.get("description", ""),
                date=start_dt,
                due_date=due_dt,
                description=t.get("description", ""),
            )
            session.add(task)
            tasks_created.append(task)

    await session.commit()

    return ChatResponse(
        response=f"Created {len(tasks_created)} tasks in category {target_category_id}.",
        usage={},
        model="mock"
    )
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
