from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List
# from uuid import UUID
from sqlalchemy import select

from app.core.security import get_current_user

from ...db.database import get_db
from ...db.db_structure import Category, User
from ..models.category import CategoryResponse, CategoryCreate, CategoryBase
# router = APIRouter(prefix="/categories", tags=["Categories"])
router = APIRouter()
# Dependency để lấy database session
# def get_db():
#     db = SessionLocal()
#     try:
#         yield db
#     finally:
#         db.close()

# Tạo category
@router.post("/categories/", response_model=CategoryResponse)
async def create_category(
    category: CategoryCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    # Kiểm tra trùng tiêu đề (của người dùng hiện tại)
    result = await db.execute(
        select(Category).where(
            Category.title == category.title,
            Category.owner_id == current_user.id
        )
    )
    db_category = result.scalar_one_or_none()
    if db_category:
        raise HTTPException(status_code=400, detail="Category already exists")

    # Tạo category mới
    new_category = Category(
        title=category.title,
        color=category.color,
        icon=category.icon,
        owner_id=current_user.id  # Gán người tạo
    )

    db.add(new_category)
    await db.commit()
    await db.refresh(new_category)

    return new_category


# Lấy danh sách tất cả category
@router.get("/categories/", response_model=List[CategoryResponse])
async def get_user_categories(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    print(f"🔐 current_user: {current_user.id}")

    result = await db.execute(
        select(Category).where(Category.owner_id == current_user.id)
    )
    categories = result.scalars().all()
    return categories




# Lấy một category theo ID
# @router.get("/categories/{category_id}", response_model=CategoryResponse)
# def get_category_by_id(category_id: int, db: AsyncSession = Depends(get_db)): 
#     category = db.query(Category).filter(Category.id == category_id).first()
#     if not category:
#         raise HTTPException(status_code=404, detail="Category not found")
#     return category

# # Cập nhật category theo ID
# @router.put("/categories/{category_id}", response_model=CategoryResponse)
# def update_category(category_id: int, updated_category: CategoryCreate, db: AsyncSession = Depends(get_db)):
#     category = db.query(Category).filter(Category.id == category_id).first()
#     if not category:
#         raise HTTPException(status_code=404, detail="Category not found")

#     category.title = updated_category.title
#     category.color = updated_category.color
#     category.icon = updated_category.icon

#     db.commit()
#     db.refresh(category)
#     return category

# Xóa category theo ID
@router.delete("/categories/{category_id}")
def delete_category(category_id: int, db: Session = Depends(get_db)):
    category = db.query(Category).filter(Category.id == category_id).first()
    if not category:
        raise HTTPException(status_code=404, detail="Category not found")

    db.delete(category)
    db.commit()
    return {"message": "Category deleted successfully"}

