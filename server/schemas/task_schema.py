from pydantic import BaseModel
from typing import Optional
import datetime
# from datetime import datetime, date, time
import uuid
from database.database import Base
from sqlalchemy import Column, Date, Integer, String, Boolean, ForeignKey
from sqlalchemy.dialects.postgresql import UUID as SA_UUID
from pydantic import validator
from typing import Optional

# class Task(Base):
#     __tablename__ = "tasks"
#     __table_args__ = {"extend_existing": True} 
    
#     id = Column(SA_UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, unique=True, index=True)
#     user_id = Column(SA_UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
#     category_id = Column(SA_UUID(as_uuid=True), ForeignKey("categories.id"), nullable=False)
#     # remind_id = Column(SA_UUID(as_uuid=True), ForeignKey("reminds.id"), nullable=True)
#     title = Column(String, nullable=False)
#     description = Column(String, nullable=True)
#     due_date = Column(date, nullable=True)
#     time = Column(time, nullable=True)
#     is_completed = Column(Boolean, default=False)  
#     created_at = Column(DateTime, default=datetime.utcnow)
#     updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
#     is_deleted = Column(Boolean, default=False)

class TaskBase(BaseModel):
    title: str
    description: Optional[str] = None
    # category_id: Optional[uuid.UUID] = None
    category_id: uuid.UUID

    # remind_id: Optional[uuid.UUID] = None  # New
    is_completed: bool = False
    # created_at: datetime
    # updated_at: datetime
    
    # is_deleted: bool = False

class TaskCreate(TaskBase):
    # pass  # Dùng khi tạo task, không cần ID
    category_id: uuid.UUID
    due_date: Optional[datetime.date] = None
    time: Optional[datetime.time] = None
    @validator("time", pre=True)
    def parse_time(cls, value):
        if isinstance(value, str):
            try:
                return datetime.datetime.strptime(value, "%I:%M %p").time()  # "7:48 AM" format
            except ValueError:
                pass  # Let Pydantic raise its default error
        return value

class TaskResponse(TaskBase):
    id: uuid.UUID  # Chỉnh sửa để sử dụng uuid.UUID
    user_id: uuid.UUID
    # category_id: Optional[uuid.UUID] = None
    category_id: uuid.UUID

    description: Optional[str] = None
    due_date: Optional[datetime.date] = None
    time: Optional[datetime.time] = None

    class Config:
        arbitrary_types_allowed = True  # Cho phép sử dụng kiểu dữ liệu không chuẩn
        from_attributes = True

class TaskUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    is_completed: Optional[bool] = None
    is_deleted: Optional[bool] = None
    category_id: Optional[str] = None