from fastapi import FastAPI, APIRouter, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from database.database import SessionLocal

from routers import user, task, category

app = FastAPI()


# Dependency: Lấy database session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Cấu hình CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Cho phép tất cả domain truy cập
    allow_credentials=True,
    allow_methods=["*"],  # Cho phép tất cả method (GET, POST, PUT, DELETE, ...)
    allow_headers=["*"],  # Cho phép tất cả headers
)

router = APIRouter()


# Đăng ký router vào app
# app.include_router(task_router)
app.include_router(task.router)
app.include_router(user.router) 
app.include_router(category.router)
