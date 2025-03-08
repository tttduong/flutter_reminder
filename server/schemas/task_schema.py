from pydantic import BaseModel
from typing import Optional
from datetime import datetime
import uuid
from database.database import Base
from sqlalchemy import Column, Integer, String, Boolean, ForeignKey, DateTime
from sqlalchemy.dialects.postgresql import UUID as SA_UUID

class Task(Base):
    __tablename__ = "tasks"
    __table_args__ = {"extend_existing": True} 
    
    id = Column(SA_UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, unique=True, index=True)
    user_id = Column(SA_UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    category_id = Column(SA_UUID(as_uuid=True), ForeignKey("categories.id"), nullable=True)
    title = Column(String, nullable=False)
    description = Column(String, nullable=True)
    is_completed = Column(Boolean, default=False)  
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    is_deleted = Column(Boolean, default=False)

class TaskBase(BaseModel):
    title: str
    description: Optional[str] = None
    category_id: Optional[uuid.UUID] = None
    is_completed: bool = False
    # created_at: datetime
    # updated_at: datetime
    # is_deleted: bool = False

class TaskCreate(TaskBase):
    pass  # Dùng khi tạo task, không cần ID

class TaskResponse(TaskBase):
    id: uuid.UUID  # Chỉnh sửa để sử dụng uuid.UUID
    user_id: uuid.UUID
    category_id: Optional[uuid.UUID] = None
    description: Optional[str] = None

    class Config:
        arbitrary_types_allowed = True  # Cho phép sử dụng kiểu dữ liệu không chuẩn
        from_attributes = True
