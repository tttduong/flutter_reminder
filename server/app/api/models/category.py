from pydantic import BaseModel

class CategoryBase(BaseModel):
    title: str
    color: str  # Lưu màu dạng chuỗi hex, ví dụ: "#FF5733"
    icon: str  # Lưu tên icon, ví dụ: "material-icons:work"
    

class CategoryCreate(CategoryBase):
    is_default: bool
    pass

class CategoryOut(BaseModel):
    id: int
    title: str
    color: str
    icon: str
    
    class Config:
        from_attributes = True

class CategoryResponse(BaseModel):
    id: int
    title: str
    color: str
    icon: str
    is_default: bool
    owner_id: int
    
    class Config:
        from_attributes = True