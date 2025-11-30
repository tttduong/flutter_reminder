import pytz
from datetime import datetime
from apscheduler.schedulers.asyncio import AsyncIOScheduler
from sqlalchemy import select
from google.oauth2 import service_account
from google.auth.transport.requests import Request
import httpx
from app.core.config import settings
from app.api.models.user_token import UserToken
from app.db.database import get_db
from app.db.db_structure import Notification

import logging
logger = logging.getLogger("scheduler")
SCOPES = ["https://www.googleapis.com/auth/firebase.messaging"]

# Timezone VN
VIETNAM_TZ = pytz.timezone("Asia/Ho_Chi_Minh")


def get_access_token():
    creds = service_account.Credentials.from_service_account_file(
        settings.GOOGLE_APPLICATION_CREDENTIALS,
        scopes=SCOPES
    )
    creds.refresh(Request())
    return creds.token


async def send_fcm_v1(token: str, title: str, body: str):
    access_token = get_access_token()

    url = f"https://fcm.googleapis.com/v1/projects/{settings.FCM_PROJECT_ID}/messages:send"

    headers = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json; UTF-8"
    }

    payload = {
        "message": {
            "token": token,
            "notification": {
                "title": title,
                "body": body
            },
            "data": {"source": "scheduled"}
        }
    }

    async with httpx.AsyncClient() as client:
        r = await client.post(url, headers=headers, json=payload)
        print("FCM Status:", r.status_code)
        print("FCM Response:", r.text)


async def process_scheduled_notifications():
    """
    Lấy các thông báo đến giờ gửi và gửi chúng.
    Chạy mỗi 1 phút.
    """

    now = datetime.now(VIETNAM_TZ)
    print(f"[Scheduler] Checking at {now}")

    async for db in get_db():
        # Lấy tất cả thông báo tới giờ mà chưa gửi
        result = await db.execute(
            select(Notification)
            .where(
                Notification.sent == False,
                Notification.send_at <= now
            )
        )
        notifications = result.scalars().all()

        for notif in notifications:
            # Lấy FCM token user
            token_result = await db.execute(
                select(UserToken.fcm_token).where(UserToken.user_id == notif.user_id)
            )
            token_row = token_result.first()

            if not token_row:
                print(f"User {notif.user_id} has no FCM token → skip")
                continue

            token = token_row[0]

            # Gửi FCM
            logger.info(f"Running job for notification_id={notif.id}")
            await send_fcm_v1(token, notif.title, notif.body)

            # Đánh dấu đã gửi
            notif.sent = True
            await db.commit()

            print(f"Sent notification → ID {notif.id}")



def start_scheduler():
    scheduler = AsyncIOScheduler(timezone=VIETNAM_TZ)

    # Chạy mỗi phút
    scheduler.add_job(
        process_scheduled_notifications,
        "interval",
        minutes=1,
        id="scheduled_notifications"
    )

    scheduler.start()
    print("Scheduler started!")
