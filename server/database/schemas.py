# def individual_data(todo):
#     return {
#         "id": str(todo.get("_id", "")),  # Ép kiểu _id thành string
#         "title": todo.get("title", "Unnamed Task"),
#         "note": todo.get("note", ""),
#         "isCompleted": todo.get("isCompleted", 0),
#         "date": todo.get("date", ""),
#         "startTime": todo.get("startTime", ""),
#         "endTime": todo.get("endTime", ""),
#         "color": todo.get("color", 0),
#         "remind": todo.get("remind", 0),
#         "repeat": todo.get("repeat", ""),
#         "is_deleted": todo.get("is_deleted", False)
#     }

# def all_tasks(todos):
#     return [individual_data(todo) for todo in todos]

from pydantic import BaseModel
from typing import Optional
from datetime import date, time
from uuid import UUID  # Nếu id đang là UUID


class TodoBase(BaseModel):
    title: str
    note: Optional[str] = None
    date: date
    start_time: time
    end_time: time
    is_completed: int = 0
    color: Optional[int] = None
    repeat: Optional[int] = None
    remind: Optional[int] = None
    is_deleted: bool = False


class TodoCreate(TodoBase):
    pass  # Dùng khi tạo task, không cần ID


class TodoResponse(TodoBase):
    id: UUID    # Thêm ID cho response

    class Config:
        from_attributes = True  # Dùng thay cho `orm_mode`

