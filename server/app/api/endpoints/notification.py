import json
from fastapi import APIRouter, Depends
from pydantic import BaseModel
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
import httpx
from google.oauth2 import service_account
from google.auth.transport.requests import Request
from app.api.models.user_token import UserToken
from app.db.database import get_db
from app.core.config import settings

router = APIRouter()

SCOPES = ["https://www.googleapis.com/auth/firebase.messaging"]

class NotificationRequest(BaseModel):
    user_id: int
    title: str
    body: str

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

async def send_push_notification(token: str, title: str, body: str):
    access_token = get_access_token()
    url = f"https://fcm.googleapis.com/v1/projects/{settings.FCM_PROJECT_ID}/messages:send"

    headers = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json; UTF-8"
    }
    payload = {
        "message": {
            "token": token,
            "notification": {"title": title, "body": body},
            "data": {"extra": "info"}  # tùy chọn
        }
    }
    async with httpx.AsyncClient() as client:
        resp = await client.post(url, headers=headers, json=payload)
        print("FCM v1 status:", resp.status_code)
        print("FCM v1 response:", resp.text)
        if resp.status_code != 200:
            return {"error": "FCM v1 error", "details": resp.text}
        return resp.json()

@router.post("/send-notification")
async def send_notification(req: NotificationRequest, db: AsyncSession = Depends(get_db)):
    token = await get_token_from_db(req.user_id, db)
    if not token:
        return {"error": "User has no FCM token"}
    result = await send_push_notification(token, req.title, req.body)
    return result
