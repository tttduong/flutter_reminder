from pydantic import BaseModel
from uuid import UUID 

class CategoryBase(BaseModel):
    title: str
    color: str  # Lưu màu dạng chuỗi hex, ví dụ: "#FF5733"
    icon: str  # Lưu tên icon, ví dụ: "material-icons:work"

class CategoryCreate(CategoryBase):
    pass

class CategoryResponse(CategoryBase):
    id: UUID 

    class Config:
        from_attributes = True
