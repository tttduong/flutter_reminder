from typing import Optional
from pydantic import BaseModel
from pydantic import BaseModel, constr


class TaskCreate(BaseModel):
    title: constr(strip_whitespace=True, min_length=1)
    description: Optional[str] = None
    category_id: int



class TaskUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    category_id: Optional[int] = None
    completed: Optional[bool] = None

class TaskResponse(BaseModel):
    id: int
    title: str
    description: str
    category_id: Optional[int] = None
    completed: bool
