
from datetime import datetime
from pydantic import BaseModel

class NotificationRequest(BaseModel):
    user_id: int
    title: str
    body: str
    send_at: datetime
    fcm_token: str


class NotificationCreate(BaseModel):
    user_id: int
    title: str
    body: str
    send_at: datetime
