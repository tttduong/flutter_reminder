# import uuid
# from sqlalchemy import Column, DateTime, Boolean, ForeignKey
# from sqlalchemy.dialects.postgresql import UUID
# from sqlalchemy.orm import relationship
# from datetime import datetime
# from database import Base

# class RemindModel(Base):
#     __tablename__ = "reminds"

#     id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True)
#     task_id = Column(UUID(as_uuid=True), ForeignKey("tasks.id"), nullable=False)
#     remind_time = Column(DateTime, nullable=False)
#     is_sent = Column(Boolean, default=False)
#     created_at = Column(DateTime, default=datetime.utcnow)
#     updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

#     task = relationship("TaskModel", back_populates="reminds")