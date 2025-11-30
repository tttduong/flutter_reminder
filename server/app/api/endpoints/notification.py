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
from app.db.db_structure import Notification

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

# async def send_push_notification(token: str, title: str, body: str):
#     access_token = get_access_token()
#     url = f"https://fcm.googleapis.com/v1/projects/{settings.FCM_PROJECT_ID}/messages:send"

#     headers = {
#         "Authorization": f"Bearer {access_token}",
#         "Content-Type": "application/json; UTF-8"
#     }
#     payload = {
#         "message": {
#             "token": token,
#             "notification": {"title": title, "body": body},
#             "data": {"extra": "info"}  # tùy chọn
#         }
#     }
#     async with httpx.AsyncClient() as client:
#         resp = await client.post(url, headers=headers, json=payload)
#         print("FCM v1 status:", resp.status_code)
#         print("FCM v1 response:", resp.text)
#         if resp.status_code != 200:
#             return {"error": "FCM v1 error", "details": resp.text}
#         return resp.json()

# @router.post("/send-notification")
# async def send_notification(req: NotificationRequest, db: AsyncSession = Depends(get_db)):
#     token = await get_token_from_db(req.user_id, db)
#     if not token:
#         return {"error": "User has no FCM token"}
#     result = await send_push_notification(token, req.title, req.body)
#     return result


# def check_scheduled_notifications(db: AsyncSession = Depends(get_db)):
#     now = datetime.utcnow()
#     upcoming = db.fetch_notifications(send_at=now)

#     for n in upcoming:
#         send_notification(title=n.title, body=n.body, token=n.token)
#         db.mark_as_sent(n.id)

async def save_scheduled_notification(data, db: AsyncSession):
    """
    Lưu thông báo cần gửi vào DB.
    data = ScheduledNotificationCreate
    """
    new_notif = Notification(
        user_id=data.user_id,
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
async def schedule_notification(data: NotificationCreate, db: AsyncSession = Depends(get_db)):
    result = await save_scheduled_notification(data, db)
    return {"message": "Scheduled notification saved", "data": result}


