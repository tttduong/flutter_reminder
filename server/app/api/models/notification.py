
from datetime import datetime
from typing import Optional
from pydantic import BaseModel

class NotificationRequest(BaseModel):
    title: str
    body: str
    send_at: datetime
    fcm_token: str


class NotificationCreate(BaseModel):
    task_id: Optional[int] = None  # ✅ Thêm task_id
    notification_type: Optional[str] = None  # ✅ Thêm type
    title: str
    body: str
    send_at: datetime
