# import pytz
# from datetime import datetime
# from apscheduler.schedulers.asyncio import AsyncIOScheduler
# from sqlalchemy import select
# from google.oauth2 import service_account
# from google.auth.transport.requests import Request
# import httpx
# from app.core.config import settings
# from app.api.models.user_token import UserToken
# from app.db.database import get_db
# from app.db.db_structure import Notification

# import logging
# logger = logging.getLogger("scheduler")
# SCOPES = ["https://www.googleapis.com/auth/firebase.messaging"]

# # Timezone VN
# VIETNAM_TZ = pytz.timezone("Asia/Ho_Chi_Minh")


# def get_access_token():
#     creds = service_account.Credentials.from_service_account_file(
#         settings.GOOGLE_APPLICATION_CREDENTIALS,
#         scopes=SCOPES
#     )
#     creds.refresh(Request())
#     return creds.token


# async def send_fcm_v1(token: str, title: str, body: str):
#     access_token = get_access_token()

#     url = f"https://fcm.googleapis.com/v1/projects/{settings.FCM_PROJECT_ID}/messages:send"

#     headers = {
#         "Authorization": f"Bearer {access_token}",
#         "Content-Type": "application/json; UTF-8"
#     }

#     payload = {
#         "message": {
#             "token": token,
#             "notification": {
#                 "title": title,
#                 "body": body
#             },
#             "data": {"source": "scheduled"}
#         }
#     }

#     async with httpx.AsyncClient() as client:
#         r = await client.post(url, headers=headers, json=payload)
#         print("FCM Status:", r.status_code)
#         print("FCM Response:", r.text)


# async def process_scheduled_notifications():
#     """
#     Lấy các thông báo đến giờ gửi và gửi chúng.
#     Chạy mỗi 1 phút.
#     """

#     now = datetime.now(VIETNAM_TZ)
#     print(f"[Scheduler] Checking at {now}")

#     async for db in get_db():
#         # Lấy tất cả thông báo tới giờ mà chưa gửi
#         result = await db.execute(
#             select(Notification)
#             .where(
#                 Notification.sent == False,
#                 Notification.send_at <= now
#             )
#         )
#         notifications = result.scalars().all()

#         for notif in notifications:
#             # Lấy FCM token user
#             token_result = await db.execute(
#                 select(UserToken.fcm_token).where(UserToken.user_id == notif.user_id)
#             )
#             token_row = token_result.first()

#             if not token_row:
#                 print(f"User {notif.user_id} has no FCM token → skip")
#                 continue

#             token = token_row[0]

#             # Gửi FCM
#             logger.info(f"Running job for notification_id={notif.id}")
#             await send_fcm_v1(token, notif.title, notif.body)

#             # Đánh dấu đã gửi
#             notif.sent = True
#             await db.commit()

#             print(f"Sent notification → ID {notif.id}")



# def start_scheduler():
#     scheduler = AsyncIOScheduler(timezone=VIETNAM_TZ)

#     # Chạy mỗi phút
#     scheduler.add_job(
#         process_scheduled_notifications,
#         "interval",
#         minutes=1,
#         id="scheduled_notifications"
#     )

#     scheduler.start()
#     print("Scheduler started!")

import logging
from apscheduler.schedulers.asyncio import AsyncIOScheduler
import pytz
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from datetime import datetime
import httpx
from app.db.db_structure import Notification
from app.api.endpoints.notification import get_access_token
from app.core.config import settings
from app.api.models.user_token import UserToken

import logging
logger = logging.getLogger(__name__)
scheduler = AsyncIOScheduler()

async def send_fcm_v1(token: str, title: str, body: str):
    """
    Gửi thông báo qua FCM
    Returns: (success: bool, error_code: str)
    """
    access_token = get_access_token()
    
    headers = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json"
    }
    
    payload = {
        "message": {
            "token": token,
            "notification": {
                "title": title,
                "body": body
            }
        }
    }
    
    try:
        async with httpx.AsyncClient() as client:
            response = await client.post(
                f"https://fcm.googleapis.com/v1/projects/{settings.FCM_PROJECT_ID}/messages:send",
                headers=headers,
                json=payload,
                timeout=10.0
            )
            
            if response.status_code == 200:
                logger.info(f"✅ FCM notification sent successfully")
                return True, None
            else:
                error_data = response.json()
                error_code = None
                
                # Lấy error code từ response
                if "error" in error_data:
                    details = error_data["error"].get("details", [])
                    for detail in details:
                        if "@type" in detail and "FcmError" in detail["@type"]:
                            error_code = detail.get("errorCode")
                
                logger.warning(f"⚠️ FCM Error {response.status_code}: {error_code}")
                return False, error_code
                
    except Exception as e:
        logger.error(f"❌ Error sending FCM: {str(e)}")
        return False, "NETWORK_ERROR"


async def process_scheduled_notifications(db: AsyncSession):
    """
    Xử lý gửi notifications đã đến hạn
    """
    VIETNAM_TZ = pytz.timezone("Asia/Ho_Chi_Minh") 
    now = datetime.now(VIETNAM_TZ)
    
    # Lấy các notifications cần gửi
    result = await db.execute(
        select(Notification).filter(
            Notification.send_at <= now,
            Notification.sent == False
        )
    )
    notifications = result.scalars().all()
    
    logger.info(f"📬 Found {len(notifications)} notifications to send")
    
    for notif in notifications:
        try:
            # Lấy FCM token của user
            token_result = await db.execute(
                select(UserToken.fcm_token).where(
                    UserToken.user_id == notif.user_id
                )
            )
            token_row = token_result.first()
            
            # ✅ KHÔNG CÓ TOKEN → BỎ QUA, RETRY SAU
            if not token_row or not token_row[0]:
                logger.warning(f"⚠️ No FCM token for user {notif.user_id} - will retry")
                continue  # ← Không commit, để retry lần sau
            
            fcm_token = token_row[0]
            
            # Gửi notification qua FCM
            success, error_code = await send_fcm_v1(
                fcm_token,
                notif.title,
                notif.body
            )
            
            if success:
                # ✅ Thành công → đánh dấu sent = True
                notif.sent = True
                await db.commit()
                logger.info(f"✅ Notification {notif.id} sent successfully")
                
            elif error_code in ["UNREGISTERED", "INVALID_ARGUMENT"]:
                # ⚠️ Token không hợp lệ → XÓA token và đánh dấu sent
                logger.warning(f"🗑️ Removing invalid FCM token for user {notif.user_id}")
                
                # Xóa tất cả token của user này
                token_objs = (await db.execute(
                    select(UserToken).where(UserToken.user_id == notif.user_id)
                )).scalars().all()

                for token_obj in token_objs:
                    await db.delete(token_obj)

                notif.sent = True  # Đánh dấu đã xử lý (token invalid)
                await db.commit()
                
            else:
                # ❌ Lỗi khác → KHÔNG set sent, retry sau
                logger.error(f"❌ Failed to send notification {notif.id}: {error_code}")
                # Không commit để retry
                
        except Exception as e:
            logger.error(f"❌ Error processing notification {notif.id}: {str(e)}")
            await db.rollback()


def start_scheduler(db_session_factory):
    """
    Khởi động scheduler
    """
    async def job():
        async with db_session_factory() as session:
            await process_scheduled_notifications(session)
    
    scheduler.add_job(
        job,
        trigger="interval",
        minutes=1,
        id="process_scheduled_notifications",
        replace_existing=True
    )
    
    scheduler.start()
    logger.info("🚀 Notification scheduler started")


def stop_scheduler():
    scheduler.shutdown()
    logger.info("🛑 Notification scheduler stopped")