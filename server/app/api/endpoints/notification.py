import json
from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
import httpx
from google.oauth2 import service_account
from google.auth.transport.requests import Request
from app.api.models.user_token import UserToken
from app.db.database import get_db
from app.core.config import settings
from datetime import datetime, timedelta
from app.api.models.notification import NotificationCreate, NotificationRequest
from app.db.db_structure import Notification, User
from app.core.session import get_current_user
from sqlalchemy.orm import Session
router = APIRouter()

SCOPES = ["https://www.googleapis.com/auth/firebase.messaging"]


async def get_token_from_db(user_id: int, db: AsyncSession):
    result = await db.execute(select(UserToken.fcm_token).where(UserToken.user_id == user_id))
    token_row = result.first()
    if token_row:
        return token_row[0]
    return None

def get_access_token():
    credentials = service_account.Credentials.from_service_account_file(
        settings.GOOGLE_APPLICATION_CREDENTIALS, scopes=SCOPES
    )
    credentials.refresh(Request())
    return credentials.token

async def save_scheduled_notification(
    data: NotificationCreate,
    db: Session,
    current_user: User
):
    """
    Lưu thông báo cần gửi vào DB với user hiện tại.
    """
    new_notif = Notification(
        user_id=current_user.id,  # dùng current_user truyền vào
        title=data.title,
        body=data.body,
        send_at=data.send_at,
        sent=False
    )

    db.add(new_notif)
    await db.commit()
    await db.refresh(new_notif)

    return new_notif


@router.post("/schedule-notification")
async def schedule_notification(
    data: NotificationCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    result = await save_scheduled_notification(data, db, current_user)
    return {"message": "Scheduled notification saved", "data": result}


