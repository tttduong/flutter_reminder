from sqlalchemy import Column, Integer, String, Boolean, ForeignKey, DateTime
from sqlalchemy.dialects.postgresql import UUID
import uuid
from database.database import Base
from datetime import datetime
from sqlalchemy.orm import relationship


class TaskModel(Base):
    __tablename__ = "tasks"
    __table_args__ = {"extend_existing": True}  # Thêm dòng này

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, unique=True, index=True)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    category_id = Column(UUID(as_uuid=True), ForeignKey("categories.id"), nullable=True)
    title = Column(String, nullable=False)
    description = Column(String, nullable=True)
    is_completed = Column(Integer, default=0)  # 0: Chưa hoàn thành, 1: Đã hoàn thành
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    is_deleted = Column(Boolean, default=False)

    category = relationship("CategoryModel", back_populates="tasks")  