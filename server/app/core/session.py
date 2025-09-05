from fastapi import HTTPException, status, Depends, Request
from typing import Optional
# from app.models import User
# from app.db import get_user_by_id
from app.db.db_structure import User
from app.db.repositories.user_repository import get_user_by_id
from app.db.database import get_db 
from sqlalchemy.ext.asyncio import AsyncSession
# async def get_session_user(request: Request, db: AsyncSession = Depends(get_db)) -> Optional[User]:
#     """
#     Lấy user từ session (nếu có).
#     """
#     user_id = request.session.get("user_id")
#     if not user_id:
#         return None
    
#     # Truy vấn DB lấy user
#     # user = await get_user_by_id(user_id)
#     user = await get_user_by_id(db, user_id)
#     return user

async def get_session_user(
    request: Request,
    db: AsyncSession = Depends(get_db)
):
    user_id = request.session.get("user_id")
    if not user_id:
        return None
    return await get_user_by_id(db, user_id)



# async def get_current_user(user=Depends(get_session_user)):
#     if not user:
#         raise HTTPException(status_code=401, detail="Not authenticated")
#     return user
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
