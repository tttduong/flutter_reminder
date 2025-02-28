from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from uuid import UUID
from datetime import datetime
from passlib.context import CryptContext

from database.database import SessionLocal
from models.user import User
from schemas.user import UserCreate, UserResponse
import uuid


router = APIRouter(prefix="/users", tags=["Users"])

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# Dependency lấy session DB
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# 1. Tạo user
@router.post("/", response_model=UserResponse)
def create_user(user: UserCreate, db: Session = Depends(get_db)):
    db_user = db.query(User).filter(User.email == user.email).first()
    if db_user:
        raise HTTPException(status_code=400, detail="Email already registered")

    hashed_password = pwd_context.hash(user.password)
    new_user = User(
        id=uuid.uuid4(),
        email=user.email,
        hashed_password=hashed_password,
        name=user.name,
        is_active=user.is_active,
        created_at=datetime.utcnow()
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user

# 2. Lấy danh sách users
@router.get("/", response_model=list[UserResponse])
def get_users(db: Session = Depends(get_db)):
    return db.query(User).all()

# 3. Lấy user theo ID
@router.get("/{user_id}", response_model=UserResponse)
def get_user(user_id: UUID, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

# 4. Cập nhật user
@router.put("/{user_id}", response_model=UserResponse)
def update_user(user_id: UUID, updated_data: UserCreate, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    user.email = updated_data.email
    user.name = updated_data.name
    user.is_active = updated_data.is_active
    user.hashed_password = pwd_context.hash(updated_data.password)

    db.commit()
    db.refresh(user)
    return user

# 5. Xóa user
@router.delete("/{user_id}")
def delete_user(user_id: UUID, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    db.delete(user)
    db.commit()
    return {"message": "User deleted successfully"}
