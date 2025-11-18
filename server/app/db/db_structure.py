from datetime import datetime, timezone
from uuid import uuid4
from sqlalchemy.dialects.postgresql import TIMESTAMP
from sqlalchemy import ARRAY, UUID, Column, Integer, String, Boolean, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.db.database import Base


class User(Base):
    __tablename__ = "user"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, index=True)
    email = Column(String, unique=True, index=True, nullable=True)
    hashed_password = Column(String)
    
    tasks = relationship("Task", back_populates="owner")
    categories = relationship("Category", back_populates="owner")
    conversations = relationship("Conversation", back_populates="user", cascade="all, delete")

class Task(Base):
    __tablename__ = "task"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True)
    description = Column(String, index=True)
    completed = Column(Boolean, default=False)
    date = Column(TIMESTAMP(timezone=True), nullable=True)
    due_date = Column(TIMESTAMP(timezone=True), nullable=True)
    completed_at = Column(DateTime(timezone=True), nullable=True)
    completed = Column(Boolean, default=False, nullable=False) 
    priority = Column(Integer, nullable=True) 

    owner_id = Column(Integer, ForeignKey("user.id"))
    category_id = Column(Integer, ForeignKey("category.id", ondelete="CASCADE"), nullable=True)
    
    owner = relationship("User", back_populates="tasks")
    category = relationship("Category", back_populates="tasks")



class Category(Base):
    __tablename__ = "category"

    id = Column(Integer, primary_key=True, unique=True, index=True)
    title = Column(String, nullable=False, unique=True)
    color = Column(String, nullable=False)  # Lưu màu sắc dưới dạng chuỗi hex
    icon = Column(String, nullable=False)   # Lưu icon dưới dạng mã
    owner_id = Column(Integer, ForeignKey("user.id"), nullable=False)

    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)


    owner = relationship("User", back_populates="categories")
    tasks = relationship("Task", back_populates="category", cascade="all, delete", passive_deletes=True)
    is_default = Column(Boolean, default=False)
#  tasks = relationship("Task", back_populates="category", cascade="all, delete")

# class Conversation(Base):
#     __tablename__ = "conversations"

#     id = Column(Integer, primary_key=True, index=True)
#     user_id = Column(Integer, ForeignKey("user.id"), nullable=False)
#     title = Column(String, default="New Chat")
#     created_at = Column(DateTime, default=datetime.utcnow)

#     messages = relationship("Message", back_populates="conversation", cascade="all, delete")



class Conversation(Base):
    __tablename__ = "conversations"

    id = Column(String, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("user.id", ondelete="CASCADE"))
    title = Column(String, nullable=False)
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())  # ✅ thêm dòng này

    user = relationship("User", back_populates="conversations")
    messages = relationship("Message", back_populates="conversation", cascade="all, delete")

class Message(Base):
    __tablename__ = "messages"

    id = Column(Integer, primary_key=True, index=True)
    conversation_id = Column(String, ForeignKey("conversations.id"))
    role = Column(String, nullable=False)  # "user", "assistant", "system"
    content = Column(String, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    conversation = relationship("Conversation", back_populates="messages")


class GoalDraft(Base):
    __tablename__ = "goal_drafts"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid4)
    user_id = Column(Integer, ForeignKey("user.id"))
    
    goal_title = Column(String, nullable=True)          # maps to "goal_title"
    measurable_target = Column(String, nullable=True)   # maps to "measurable_target"
    daily_action = Column(String, nullable=True)        # maps to "daily_action"
    start_date = Column(DateTime, nullable=True)        # maps to "start_date"
    duration = Column(String, nullable=True)
    end_date = Column(DateTime, nullable=True)          # maps to "end_date"
    
    fields_missing = Column(ARRAY(String), nullable=True)  # list of missing fields
    status = Column(String, default="collecting")         # collecting | ready | confirmed
