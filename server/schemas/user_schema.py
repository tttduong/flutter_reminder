from pydantic import BaseModel, EmailStr
from uuid import UUID
from typing import Optional
from datetime import datetime

class UserBase(BaseModel):
    email: EmailStr
    name: Optional[str] = None
    is_active: bool = True
    created_at: datetime = datetime.utcnow()

class UserCreate(UserBase):
    password: str  # Người dùng nhập mật khẩu khi tạo tài khoản

class UserResponse(UserBase):
    id: UUID

    class Config:
        from_attributes = True
