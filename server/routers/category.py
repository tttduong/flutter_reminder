from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database.database import SessionLocal
from models.category_model import CategoryModel
from schemas.category_schema import CategoryCreate, CategoryResponse
from typing import List
from uuid import UUID

router = APIRouter(prefix="/categories", tags=["Categories"])

# Dependency để lấy database session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Tạo category
@router.post("/", response_model=CategoryResponse)
def create_category(category: CategoryCreate, db: Session = Depends(get_db)):
    db_category = db.query(CategoryModel).filter(CategoryModel.name == category.name).first()
    if db_category:
        raise HTTPException(status_code=400, detail="Category already exists")

    new_category = CategoryModel(name=category.name)
    db.add(new_category)
    db.commit()
    db.refresh(new_category)
    return new_category

# Lấy danh sách tất cả category
@router.get("/", response_model=List[CategoryResponse])
def get_categories(db: Session = Depends(get_db)):
    return db.query(CategoryModel).all()

# Lấy một category theo ID
@router.get("/{category_id}", response_model=CategoryResponse)
def get_category_by_id(category_id: UUID, db: Session = Depends(get_db)): 
    category = db.query(CategoryModel).filter(CategoryModel.id == category_id).first()
    if not category:
        raise HTTPException(status_code=404, detail="Category not found")
    return category


# Cập nhật category theo ID
@router.put("/{category_id}", response_model=CategoryResponse)
def update_category(category_id: UUID, updated_category: CategoryCreate, db: Session = Depends(get_db)):
    category = db.query(CategoryModel).filter(CategoryModel.id == category_id).first()
    if not category:
        raise HTTPException(status_code=404, detail="Category not found")

    category.name = updated_category.name
    db.commit()
    db.refresh(category)
    return category

# Xóa category theo ID
@router.delete("/{category_id}")
def delete_category(category_id: UUID, db: Session = Depends(get_db)):
    category = db.query(CategoryModel).filter(CategoryModel.id == category_id).first()
    if not category:
        raise HTTPException(status_code=404, detail="Category not found")

    db.delete(category)
    db.commit()
    return {"message": "Category deleted successfully"}
