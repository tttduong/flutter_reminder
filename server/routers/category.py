from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy.ext.asyncio import AsyncSession
from database.database import get_db  
from models.category_model import CategoryModel
from schemas.category_schema import CategoryCreate, CategoryResponse
from typing import List
from uuid import UUID
from sqlalchemy import select

router = APIRouter(prefix="/categories", tags=["Categories"])

# Dependency để lấy database session
# def get_db():
#     db = SessionLocal()
#     try:
#         yield db
#     finally:
#         db.close()

# Tạo category
@router.post("/", response_model=CategoryResponse)
def create_category(category: CategoryCreate, db: AsyncSession = Depends(get_db)):
    db_category = db.query(CategoryModel).filter(CategoryModel.title == category.title).first()
    if db_category:
        raise HTTPException(status_code=400, detail="Category already exists")

    new_category = CategoryModel(
        title=category.title,
        color=category.color,
        icon=category.icon
    )
    db.add(new_category)
    db.commit()
    db.refresh(new_category)
    return new_category

# Lấy danh sách tất cả category
@router.get("/", response_model=List[CategoryResponse])
async def get_categories(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(CategoryModel))
    categories = result.scalars().all()
    return categories

# Lấy một category theo ID
@router.get("/{category_id}", response_model=CategoryResponse)
def get_category_by_id(category_id: UUID, db: AsyncSession = Depends(get_db)): 
    category = db.query(CategoryModel).filter(CategoryModel.id == category_id).first()
    if not category:
        raise HTTPException(status_code=404, detail="Category not found")
    return category

# Cập nhật category theo ID
@router.put("/{category_id}", response_model=CategoryResponse)
def update_category(category_id: UUID, updated_category: CategoryCreate, db: AsyncSession = Depends(get_db)):
    category = db.query(CategoryModel).filter(CategoryModel.id == category_id).first()
    if not category:
        raise HTTPException(status_code=404, detail="Category not found")

    category.name = updated_category.name
    category.color = updated_category.color
    category.icon = updated_category.icon

    db.commit()
    db.refresh(category)
    return category

# Xóa category theo ID
@router.delete("/{category_id}")
def delete_category(category_id: UUID, db: AsyncSession = Depends(get_db)):
    category = db.query(CategoryModel).filter(CategoryModel.id == category_id).first()
    if not category:
        raise HTTPException(status_code=404, detail="Category not found")

    db.delete(category)
    db.commit()
    return {"message": "Category deleted successfully"}
