from fastapi import HTTPException, status, Depends, Request
from typing import Optional
from app.db.db_structure import User
from app.db.repositories.user_repository import get_user_by_id
from app.db.database import get_db 
from sqlalchemy.ext.asyncio import AsyncSession

# SESSION_CONFIG = {
#     'secret_key': 'your-secret-key',  # Phải có
#     'session_cookie': 'sessionid',
#     'max_age': 1209600,  # 14 days
#     'same_site': 'none',  # ⭐ QUAN TRỌNG cho mobile
#     'https_only': False,  # False vì đang dùng HTTP
# }

async def get_session_user(
    request: Request,
    db: AsyncSession = Depends(get_db)
):
    user_id = request.session.get("user_id")
    if not user_id:
        return None
    return await get_user_by_id(db, user_id)

async def get_current_user(request: Request, db=Depends(get_db)):
    print(">>>>Request cookies:", request.cookies)
    print(">>>>>Request session:", request.session)
    user_id = request.session.get("user_id")
    if not user_id:
        raise HTTPException(401, "Unauthorized")

    user = await get_user_by_id(db, user_id)
    if not user:
        raise HTTPException(401, "User not found")

    return user
