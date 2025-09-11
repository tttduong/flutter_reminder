from http.client import HTTPException
import json
from fastapi import FastAPI, Depends, BackgroundTasks, APIRouter
from pydantic import BaseModel
import os
from app.core.config import settings
from app.services.llm_service import LLMService
from typing import List, Dict, Optional

from app.core.session import get_current_user
from app.db.db_structure import User
from datetime import datetime, date
import json
router = APIRouter()
app = FastAPI(title="Groq LLM API", version="1.0.0")


class ChatRequest(BaseModel):
    message: str
    model: str = "llama-3.1-8b-instant"  # Default Groq model
    system_prompt: Optional[str] = None  # ← THÊM SYSTEM PROMPT
    conversation_history: Optional[List[Dict[str, str]]] = []  # ← THÊM LỊCH SỬ

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
@router.post("/chat/parse_task", response_model=TaskIntentResponse)
async def parse_task(
    req: ChatRequest,
    llm_service: LLMService = Depends(get_llm_service),
    current_user: User = Depends(get_current_user)
):
    try:
        system_prompt = """
            You are a task parser assistant.
            Extract structured task information from user messages.

            Rules:
            - If the input contains a schedule or a list of tasks with times, return an array of tasks (JSON list).
            - If the user asks to create or schedule something, always return "intent": "create_task".
            - If the user says anything with "task", "reminder", "schedule", "wake up", "meet", "plan", etc → always "create_task".
            - If the user just chats, return "intent": "small_talk".
            - If input is a schedule or a list of activities (e.g., "2:00 PM - 2:30 PM: Coding Project"), treat each entry as a task with "intent": "create_task".
            - Always prefer "create_task" over "small_talk" if there are action items, times, or tasks mentioned.
            - If no date/time is given, use the current datetime (YYYY-MM-DDTHH:MM:SS).
            - "due_date" can be null.

            Return ONLY valid JSON with fields:
            {
            "intent": "create_task" | "small_talk",
            "title": "<short title>",
            "description": "<optional description, default empty>",
            "category_id": 57,
            "date": "YYYY-MM-DDTHH:MM:SS",
            "due_date": "YYYY-MM-DDTHH:MM:SS" | null
            }
            """


        messages = [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": req.message}
        ]

        result = await llm_service.generate_response_with_messages(
            messages=messages,
            model=req.model
        )

        raw_response = result["response"].strip()
        parsed = json.loads(raw_response)

        parsed = json.loads(raw_response)

        intent = parsed.get("intent", "small_talk")
        title = parsed.get("title", "")

        # nếu không có date/time thì dùng datetime.now()
        date_str = parsed.get("date")
        if date_str:
            start_datetime = datetime.fromisoformat(date_str)
        else:
            start_datetime = datetime.now()


        # nếu không có due_date thì để None
        due_datetime = None
        # if date_str and time_str:
        #     due_datetime = start_datetime + timedelta(hours=1)

        return TaskIntentResponse(
            intent=intent,
            title=title,
            description=parsed.get("description", ""),  # default ""
            category_id=parsed.get("category_id", 57),   # default category
            date=start_datetime,
            due_date=due_datetime
        )

    except Exception as e:
        now = datetime.now()
        return TaskIntentResponse(
            intent="small_talk",
            title="",
            description="",
            category_id=1,
            date=now,
            due_date=None   
        )
@router.post("/chat/", response_model=ChatResponse)
async def chat_endpoint(
    request: ChatRequest, 
    llm_service: LLMService = Depends(get_llm_service),
    current_user: User = Depends(get_current_user)
):
    """
    Chat endpoint sử dụng Groq API với system prompt và lịch sử hội thoại
    """
    
    # Tạo messages array cho OpenAI format
    messages = []
    
    # 1. THÊM SYSTEM MESSAGE NẾU CÓ
    if request.system_prompt:
        messages.append({
            "role": "system",
            "content": request.system_prompt
        })
    
    # 2. THÊM LỊCH SỬ HỘI THOẠI
    if request.conversation_history:
        messages.extend(request.conversation_history)
    
    # 3. THÊM MESSAGE HIỆN TẠI
    messages.append({
        "role": "user", 
        "content": request.message
    })
    
    # Debug log
    print("=== MESSAGES SENT TO GROQ ===")
    for msg in messages:
        print(f"{msg['role']}: {msg['content']}")
    print("============================")
    
    # 4. GỬI TỚI LLM SERVICE
    result = await llm_service.generate_response_with_messages(
        messages=messages, 
        model=request.model
    )
    
    return ChatResponse(
        response=result["response"],
        usage=result["usage"],
        model=result["model"]
    )
# # Dependency để tạo LLM service
# async def get_llm_service():
    
#     llm_service = LLMService(
#         api_key= settings.CHAT_KEY,
#         base_url="https://api.groq.com/openai/v1"
#     )
#     try:
#         yield llm_service  
#     finally:
#         await llm_service.close()

# @router.post("/chat/", response_model=ChatResponse)
# async def chat_endpoint(
#     request: ChatRequest, 
#     llm_service: LLMService = Depends(get_llm_service)
# ):
#     """
#     Chat endpoint sử dụng Groq API
#     """
#     result = await llm_service.generate_response(request.message, request.model)
    
#     return ChatResponse(
#         response=result["response"],
#         usage=result["usage"],
#         model=result["model"]
#     )

# @router.get("/health/")
# async def health_check():
#     return {"status": "healthy", "service": "groq-llm-api"}

# @router.get("/models/")
# async def get_available_models():
#     """
#     Danh sách các models có sẵn trên Groq
#     """
#     return {
#         "models": [
#             "llama-3.1-70b-versatile",
#             "llama-3.1-8b-instant", 
#             "mixtral-8x7b-32768",
#             "gemma2-9b-it",
#             "meta-llama/llama-4-scout-17b-16e-instruct"
#         ]
#     }
