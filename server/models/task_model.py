from sqlalchemy import Column, Date, Time, Integer, String, Boolean, ForeignKey, DateTime
from sqlalchemy.dialects.postgresql import UUID
import uuid
from database.database import Base
from datetime import datetime
from sqlalchemy.orm import relationship


class TaskModel(Base):
    __tablename__ = "tasks"
    __table_args__ = {"extend_existing": True}

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, unique=True, index=True)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    category_id = Column(UUID(as_uuid=True), ForeignKey("categories.id"), nullable=True)
    title = Column(String, nullable=False)
    description = Column(String, nullable=True)
    due_date = Column(Date, nullable=True)  # YYYY-MM-DD
    time = Column(Time, nullable=True)  # HH:MM:SS
    is_completed = Column(Boolean, default=False)  # 0: Chưa hoàn thành, 1: Đã hoàn thành
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    is_deleted = Column(Boolean, default=False)

    category = relationship("CategoryModel", back_populates="tasks")  
    # reminds = relationship("RemindModel", back_populates="task", cascade="all, delete-orphan", passive_deletes=True)

# class RemindModel(Base):
#     __tablename__ = "reminds"

#     id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True)
#     task_id = Column(UUID(as_uuid=True), ForeignKey("tasks.id"), nullable=False)
#     remind_time = Column(DateTime, nullable=False)
#     is_sent = Column(Boolean, default=False)
#     created_at = Column(DateTime, default=datetime.utcnow)
#     updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

#     task = relationship("TaskModel", back_populates="reminds", foreign_keys="RemindModel.task_id")
