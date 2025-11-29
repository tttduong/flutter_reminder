from sqlalchemy import Column, Integer, String, ForeignKey, DateTime, Boolean
from sqlalchemy.ext.declarative import declarative_base
from datetime import datetime

Base = declarative_base()

class UserToken(Base):
    __tablename__ = "user_tokens"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, index=True)
    fcm_token = Column(String, unique=True, index=True)
    created_at = Column(DateTime, default=datetime.utcnow)
