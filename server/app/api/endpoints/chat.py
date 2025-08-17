from fastapi import FastAPI, Depends, BackgroundTasks, APIRouter
from pydantic import BaseModel
import os
from app.core.config import settings
from app.services.llm_service import LLMService

router = APIRouter()
app = FastAPI(title="Groq LLM API", version="1.0.0")

class ChatRequest(BaseModel):
    message: str
    model: str = "llama3-70b-8192"  # Default Groq model

class ChatResponse(BaseModel):
    response: str
    usage: dict = {}
    model: str

# Dependency để tạo LLM service
async def get_llm_service():
    
    llm_service = LLMService(
        api_key= settings.CHAT_KEY,
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
    Chat endpoint sử dụng Groq API
    """
    result = await llm_service.generate_response(request.message, request.model)
    
    return ChatResponse(
        response=result["response"],
        usage=result["usage"],
        model=result["model"]
    )

@router.get("/health/")
async def health_check():
    return {"status": "healthy", "service": "groq-llm-api"}

@router.get("/models/")
async def get_available_models():
    """
    Danh sách các models có sẵn trên Groq
    """
    return {
        "models": [
            "llama-3.1-70b-versatile",
            "llama-3.1-8b-instant", 
            "mixtral-8x7b-32768",
            "gemma2-9b-it",
            "meta-llama/llama-4-scout-17b-16e-instruct"
        ]
    }
