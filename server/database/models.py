from pydantic import BaseModel
from datetime import datetime
from database.database import Base
from sqlalchemy import Column, Integer, String, Boolean
from sqlalchemy.dialects.postgresql import UUID
import uuid

class Todo(Base):
    __tablename__ = "tasks"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, unique=True, index=True)
    title = Column(String, nullable=False)
    note = Column(String, nullable=True)
    date = Column(String, nullable=False)
    start_time = Column(String, nullable=False)
    end_time = Column(String, nullable=False)
    is_completed = Column(Integer, default=0)  # 0: chưa hoàn thành, 1: đã hoàn thành
    color = Column(Integer, nullable=True)  # Mã màu (ví dụ: RGB, HEX lưu dưới dạng số)
    repeat = Column(Integer, nullable=True)  # Tần suất lặp lại (ví dụ: số ngày, tuần)
    remind = Column(Integer, nullable=True)  # Nhắc nhở trước bao nhiêu phút
    is_deleted = Column(Boolean, default=False)