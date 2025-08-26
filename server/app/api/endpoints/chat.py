from fastapi import FastAPI, Depends, BackgroundTasks, APIRouter
from pydantic import BaseModel
import os
from app.core.config import settings
from app.services.llm_service import LLMService
from typing import List, Dict, Optional
router = APIRouter()
app = FastAPI(title="Groq LLM API", version="1.0.0")


class ChatRequest(BaseModel):
    message: str
    model: str = "llama3-70b-8192"  # Default Groq model
    system_prompt: Optional[str] = None  # ← THÊM SYSTEM PROMPT
    conversation_history: Optional[List[Dict[str, str]]] = []  # ← THÊM LỊCH SỬ

class ChatResponse(BaseModel):
    response: str
    usage: dict = {}
    model: str
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

@router.post("/chat/", response_model=ChatResponse)
async def chat_endpoint(
    request: ChatRequest, 
    llm_service: LLMService = Depends(get_llm_service)
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
