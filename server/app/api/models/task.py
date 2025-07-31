from datetime import datetime
from typing import Optional
from pydantic import BaseModel, constr, validator

class TaskCreate(BaseModel):
    title: constr(strip_whitespace=True, min_length=1)
    description: Optional[str] = None
    category_id: int
    date: Optional[datetime] = None
    due_date: Optional[datetime] = None
    @validator("date")
    def ensure_timezone_aware(cls, v):
        if v and v.tzinfo is None:
            raise ValueError("Datetime must be timezone-aware (e.g. UTC).")
        return v



class TaskUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    category_id: Optional[int] = None
    completed: Optional[bool] = None
    date: Optional[datetime] = None
    due_date: Optional[datetime] = None

class TaskResponse(BaseModel):
    id: int
    title: str
    description: Optional[str] = None
    category_id: Optional[int] = None
    completed: bool
    date: Optional[datetime] = None
    due_date: Optional[datetime] = None
    class Config:
            from_attributes = True  # Để Pydantic có thể convert từ SQLAlchemy model