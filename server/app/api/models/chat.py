# # models/chat.py

# from sqlalchemy import Column, Integer, String, ForeignKey, DateTime, JSON
# from sqlalchemy.orm import relationship
# from datetime import datetime
# from db import Base  # từ file database.py bạn đã cấu hình

# class Conversation(Base):
#     __tablename__ = "conversations"

#     id = Column(Integer, primary_key=True, index=True)
#     user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
#     title = Column(String, default="New Chat")
#     created_at = Column(DateTime, default=datetime.utcnow)

#     messages = relationship("Message", back_populates="conversation", cascade="all, delete")


# class Message(Base):
#     __tablename__ = "messages"

#     id = Column(Integer, primary_key=True, index=True)
#     conversation_id = Column(Integer, ForeignKey("conversations.id"))
#     role = Column(String, nullable=False)  # "user", "assistant", "system"
#     content = Column(String, nullable=False)
#     created_at = Column(DateTime, default=datetime.utcnow)

#     conversation = relationship("Conversation", back_populates="messages")
