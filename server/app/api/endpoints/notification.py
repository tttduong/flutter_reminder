import json
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession
import httpx
from google.oauth2 import service_account
from google.auth.transport.requests import Request
from app.api.models.user_token import UserToken
from app.db.database import get_db
from app.core.config import settings
from datetime import datetime, timedelta
from app.api.models.notification import NotificationCreate, NotificationRequest
from app.db.db_structure import Notification, Task, User
from app.core.session import get_current_user

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
    db: AsyncSession,
    current_user: User
):
    """
    Lưu thông báo cần gửi vào DB với user hiện tại.
    """
    new_notif = Notification(
        user_id=current_user.id,
        title=data.title,
        body=data.body,
        send_at=data.send_at,
        sent=False
    )

    db.add(new_notif)
    await db.commit()
    await db.refresh(new_notif)

    return new_notif


# API endpoint để tạo notification
@router.post("/schedule-notification")
async def schedule_notification(
    notification: NotificationCreate,
    db: AsyncSession = Depends(get_db),  # ✅ Sửa: AsyncSession
    current_user: User = Depends(get_current_user)
):
    try:
        # Kiểm tra nếu có task_id thì task phải tồn tại và thuộc về user
        if notification.task_id:
            result = await db.execute(  # ✅ Sửa: await db.execute
                select(Task).filter(
                    Task.id == notification.task_id,
                    Task.owner_id == current_user.id
                )
            )
            task = result.scalar_one_or_none()  # ✅ Sửa: scalar_one_or_none
            
            if not task:
                raise HTTPException(status_code=404, detail="Task not found")
        
        # Tạo notification mới
        new_notification = Notification(
            user_id=current_user.id,
            task_id=notification.task_id,
            notification_type=notification.notification_type,
            title=notification.title,
            body=notification.body,
            send_at=notification.send_at,
            sent=False
        )
        
        db.add(new_notification)
        await db.commit()  # ✅ Sửa: await
        await db.refresh(new_notification)  # ✅ Sửa: await
        
        return {
            "status": "success",
            "notification_id": new_notification.id,
            "message": "Notification scheduled successfully"
        }
    
    except HTTPException:
        raise
    except Exception as e:
        await db.rollback()  # ✅ Sửa: await
        print(f"❌ Error scheduling notification: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))


# API endpoint để xóa task (notifications sẽ tự động xóa nhờ cascade)
@router.delete("/tasks/{task_id}")
async def delete_task(
    task_id: int,
    db: AsyncSession = Depends(get_db),  # ✅ Sửa: AsyncSession
    current_user: User = Depends(get_current_user)
):
    # Tìm task
    result = await db.execute(  # ✅ Sửa: await db.execute
        select(Task).filter(
            Task.id == task_id,
            Task.owner_id == current_user.id
        )
    )
    task = result.scalar_one_or_none()  # ✅ Sửa: scalar_one_or_none
    
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    
    # Đếm số notifications sẽ bị xóa (để log)
    count_result = await db.execute(  # ✅ Sửa: await
        select(func.count()).select_from(Notification).filter(
            Notification.task_id == task_id
        )
    )
    notification_count = count_result.scalar()  # ✅ Sửa: scalar
    
    # Xóa task (notifications sẽ tự động xóa nhờ cascade="all, delete-orphan")
    await db.delete(task)  # ✅ Sửa: await
    await db.commit()  # ✅ Sửa: await
    
    return {
        "status": "success",
        "message": f"Task deleted successfully. {notification_count} notifications also deleted."
    }


# API endpoint để lấy tất cả notifications của một task
@router.get("/tasks/{task_id}/notifications")
async def get_task_notifications(
    task_id: int,
    db: AsyncSession = Depends(get_db),  # ✅ Sửa: AsyncSession
    current_user: User = Depends(get_current_user)
):
    # Kiểm tra task có tồn tại và thuộc về user không
    result = await db.execute(  # ✅ Sửa: await db.execute
        select(Task).filter(
            Task.id == task_id,
            Task.owner_id == current_user.id
        )
    )
    task = result.scalar_one_or_none()  # ✅ Sửa: scalar_one_or_none
    
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    
    # Lấy tất cả notifications của task
    notifications_result = await db.execute(  # ✅ Sửa: await
        select(Notification).filter(
            Notification.task_id == task_id
        )
    )
    notifications = notifications_result.scalars().all()  # ✅ Sửa: scalars().all()
    
    return {
        "task_id": task_id,
        "task_title": task.title,
        "notifications": [
            {
                "id": n.id,
                "type": n.notification_type,
                "title": n.title,
                "body": n.body,
                "send_at": n.send_at,
                "sent": n.sent,
                "is_read": n.is_read
            }
            for n in notifications
        ]
    }


# API endpoint để xóa một notification cụ thể
@router.delete("/notifications/{notification_id}")
async def delete_notification(
    notification_id: int,
    db: AsyncSession = Depends(get_db),  # ✅ Sửa: AsyncSession
    current_user: User = Depends(get_current_user)
):
    result = await db.execute(  # ✅ Sửa: await db.execute
        select(Notification).filter(
            Notification.id == notification_id,
            Notification.user_id == current_user.id
        )
    )
    notification = result.scalar_one_or_none()  # ✅ Sửa: scalar_one_or_none
    
    if not notification:
        raise HTTPException(status_code=404, detail="Notification not found")
    
    await db.delete(notification)  # ✅ Sửa: await
    await db.commit()  # ✅ Sửa: await
    
    return {"status": "success", "message": "Notification deleted successfully"}
