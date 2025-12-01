
from datetime import datetime
from pydantic import BaseModel

class NotificationRequest(BaseModel):
    title: str
    body: str
    send_at: datetime
    fcm_token: str


class NotificationCreate(BaseModel):
    title: str
    body: str
    send_at: datetime
