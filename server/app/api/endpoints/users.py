
from fastapi.responses import JSONResponse
from app.core.session import get_current_user
from app.db.repositories.user_repository import authenticate_user, get_user_by_id
from app.api.models.user_token import UserToken
from ..models.category import CategoryOut
from sqlalchemy import select 
from typing import Annotated, Optional

from fastapi import APIRouter, Depends, HTTPException, Request, Response
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
# from passlib.context import CryptContext
from sqlalchemy.ext.asyncio import AsyncSession
from ..models.user import LoginSchema, UserCreate, UserOut, UserResponse
from ...core.security import get_password_hash, create_access_token, get_user_by_token, verify_password
from ...db.database import get_db
from ...db.db_structure import Category, User

router = APIRouter()
# pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

@router.post("/logout")
async def logout(request: Request):
    request.session.clear()
    return {"message": "Logged out successfully"}

@router.post("/login")
async def login(
    request: Request, 
    data: LoginSchema, 
    db: AsyncSession = Depends(get_db)
):
    email = data.email
    password = data.password

    result = await db.execute(select(User).where(User.email == email))
    user = result.scalar_one_or_none()
    if not user or not verify_password(password, user.hashed_password):
        raise HTTPException(status_code=400, detail="Incorrect email or password")

    result = await db.execute(
        select(Category).where(
            (Category.owner_id == user.id)
            & (Category.is_default == True)
            & (Category.title == "My Notes")
        )
    )
    inbox_category = result.scalar_one_or_none()

    # ✅ Chỉ cần set session, SessionMiddleware sẽ tự động tạo cookie
    request.session["user_id"] = user.id

    print("✅ Session set:", request.session)

    response = JSONResponse(content={"message": "Login successful"})
    print("🍪 Cookies sent:", response.raw_headers)

    # ✅ Trả kết quả JSON
    return {
        "status": "logged_in",
        "user": {
            "id": user.id,
            "email": user.email,
            "username": user.username,
        },
        "default_category": {
            "id": inbox_category.id,
            "title": inbox_category.title,
            "color": inbox_category.color,
            "icon": inbox_category.icon,
        } if inbox_category else None
    }



@router.post("/register", response_model=UserOut)
async def register(user_create: UserCreate, db: Session = Depends(get_db)):
    # Check if user exists
    result = await db.execute(select(User).where(User.email == user_create.email))
    existing_user = result.scalar_one_or_none()
    if existing_user:
        raise HTTPException(status_code=400, detail="Email already registered")

    # Tạo user
    hashed_password = get_password_hash(user_create.password)
    new_user = User(username=user_create.username,email=user_create.email, hashed_password=hashed_password)
    db.add(new_user)
    await db.flush()  # 👈 Lấy ID user mới ngay sau khi add

    # ✅ Tạo category mặc định 
    inbox_category = Category(title="My Notes", color = "#000000", icon = "58040", owner_id=new_user.id, is_default = True)
    db.add(inbox_category)

    await db.commit()
    await db.refresh(new_user)

    return new_user


# Helper function to get default category
async def get_user_default_category(db: Session, user_id: int) -> Optional[Category]:
    result = await db.execute(
        select(Category).where(
            (Category.owner_id == user_id) &
            (Category.is_default == True) & 
            (Category.title == "My Notes")
        )
    )
    return result.scalar_one_or_none()
@router.get("/me", response_model=UserResponse)
async def read_users_me(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    inbox_category = await get_user_default_category(db, current_user.id)
    
    return UserResponse(
        user=UserOut.from_orm(current_user),
        default_category=CategoryOut.from_orm(inbox_category) if inbox_category else None
    )

@router.post("/save-token")
async def save_token(user_id: int, fcm_token: str, db: AsyncSession = Depends(get_db)):
    token_obj = UserToken(user_id=user_id, fcm_token=fcm_token)
    db.add(token_obj)
    await db.commit()
    return {"success": True}


@router.get("/about_me", response_model=UserResponse)
def read_user(db: Session = Depends(get_db), username: str = Depends(get_user_by_token)):
    user = db.query(User).filter(User.username == username).first()
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return user