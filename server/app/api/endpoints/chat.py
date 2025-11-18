from http.client import HTTPException
import json
import uuid
from fastapi import FastAPI, Depends, BackgroundTasks, APIRouter,  HTTPException, status
from pydantic import BaseModel
import os

from sqlalchemy import select
from app.core.config import settings
from app.services.llm_service import LLMService
from typing import List, Dict, Optional
from app.db.db_structure import Category, Conversation, GoalDraft, Message
from app.core.session import get_current_user
from app.db.db_structure import User
from datetime import datetime, date
import json
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.database import get_db
from app.api.models.conversation import ConversationResponse
from app.api.prompts import DEFAULT_CHAT_PROMPT, DEFAULT_TASK_PARSER_PROMPT, GOAL_ANALYZER_PROMPT
router = APIRouter()
app = FastAPI(title="Groq LLM API", version="1.0.0")


class ChatRequest(BaseModel):
    conversation_id: Optional[str] = None
    message: str
    model: str = "llama-3.1-8b-instant"  # Default Groq model
    # model: str = "openai/gpt-oss-120b"
    # system_prompt: Optional[str] = None  
    conversation_history: Optional[List[Dict[str, str]]] = []  

class ChatResponse(BaseModel):
    response: str
    usage: dict = {}
    model: str

class TaskIntentResponse(BaseModel):
    # intent: str
    # title: str
    # date: str
    # time: str
    intent: str
    title: str
    description: str
    category_id: int
    date: datetime
    due_date: Optional[datetime] = None 
# Dependency để tạo LLM service
async def get_llm_service():
    llm_service = LLMService(
        api_key=settings.CHAT_KEY,
        base_url="https://api.groq.com/openai/v1"
    )
    try:
        yield llm_service  
    finally:
        await llm_service.close()

@router.post("/chat/goal", response_model=ChatResponse)
async def chat_goal(
    req: ChatRequest,
    llm_service: LLMService = Depends(get_llm_service),
    current_user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db)
):
    # 1️⃣ Lấy hoặc tạo Conversation
    conversation = await session.scalar(
        select(Conversation)
        .where(Conversation.id == req.conversation_id, Conversation.user_id == current_user.id)
    )
    if not conversation:
        conversation = Conversation(
            id=str(uuid.uuid4()),
            user_id=current_user.id,
            title="Goal Chat",
            created_at=datetime.utcnow(),
            updated_at=datetime.utcnow()
        )
        session.add(conversation)
        await session.flush()

    # 2️⃣ Lấy hoặc tạo GoalDraft
    draft = await session.scalar(
        select(GoalDraft)
        .where(GoalDraft.user_id == current_user.id, GoalDraft.status == "collecting")
    )
    if not draft:
        draft = GoalDraft(
            user_id=current_user.id,
            goal_title=None,
            measurable_target=None,
            daily_action=None,
            start_date=None,
            duration=None,
            end_date=None,
            status="collecting"
        )
        # Tính fields_missing dựa trên field thực sự còn trống
        draft.fields_missing = [
            f for f in ["goal_title","measurable_target","daily_action","start_date","duration","end_date"]
            if getattr(draft, f) is None
        ]
        session.add(draft)
        await session.flush()


    # 3️⃣ Tạo danh sách messages (system + lịch sử + user)
    # messages = [{"role": "system", "content": DEFAULT_CHAT_PROMPT}]
    messages = [{"role": "system", "content": GOAL_ANALYZER_PROMPT}]
    db_messages = (await session.scalars(
        select(Message)
        .where(Message.conversation_id == conversation.id)
        .order_by(Message.created_at)
    )).all()
    for msg in db_messages:
        messages.append({"role": msg.role, "content": msg.content})

    # Thêm user message mới
    user_message = Message(
        conversation_id=conversation.id,
        role="user",
        content=req.message
    )
    session.add(user_message)
    messages.append({"role": "user", "content": req.message})

    # 4️⃣ Gọi LLM
    result = await llm_service.generate_response_with_messages(
        messages=messages,
        model=req.model
    )
    print(f"LLM Response: {result['response']}")
    # 5️⃣ Lưu phản hồi AI
    ai_message = Message(
        conversation_id=conversation.id,
        role="assistant",
        content=result["response"]
    )
    session.add(ai_message)
    await session.commit()

    # 6️⃣ Cập nhật draft với JSON từ LLM
    try:
        # json_line = result["response"].splitlines()[-1]
        # parsed = json.loads(json_line)
        # lấy đoạn nằm giữa hai dấu ```
        text = result["response"]
        if "```" in text:
            json_part = text.split("```")[1]
        else:
            json_part = text

        parsed = json.loads(json_part)
    except Exception:
        parsed = {"intent": "small_talk", "fields_missing": []}

   # Update draft với JSON từ LLM
    if parsed.get("intent") == "create_goal":
        for field in ["goal_title", "measurable_target", "daily_action", "start_date", "end_date", "duration"]:
            val = parsed.get(field)
            if val:
                setattr(draft, field, val)

        # Chỉ hỏi những field còn thiếu
        draft.fields_missing = parsed.get("fields_missing", [])

        # Nếu duration đã có, bỏ end_date ra khỏi fields_missing
        if draft.duration and "end_date" in draft.fields_missing:
            draft.fields_missing.remove("end_date")

        await session.commit()

    # Chuẩn bị tin nhắn follow-up nếu còn thiếu
    if draft.fields_missing:
        questions = {
            "goal_title": "What's the title of your goal?",
            "measurable_target": "What's the specific result you want to achieve?",
            "daily_action": "What will you do daily to reach it?",
            "start_date": "When do you want to start?",
            "duration": "How long do you want this goal to take?",
            "end_date": "When do you want to finish?"
        }

        # Nếu duration đã có, bỏ end_date ra khỏi follow-up
        follow_up_fields = draft.fields_missing.copy()
        if draft.duration and "end_date" in follow_up_fields:
            follow_up_fields.remove("end_date")

        follow_up = [questions[f] for f in follow_up_fields if f in questions]

        follow_up_message = "✨ Let's complete your goal by answering:\n" + "\n".join(follow_up)
        return ChatResponse(
            response=follow_up_message,
            usage=result.get("usage"),
            model=result.get("model")
        )



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
    # if request.system_prompt:
    #     messages.append({"role": "system", "content": DEFAULT_CHAT_PROMPT})
    messages.append({"role": "system", "content": DEFAULT_CHAT_PROMPT})

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




