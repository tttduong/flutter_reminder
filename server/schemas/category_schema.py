from pydantic import BaseModel
from uuid import UUID 

class CategoryBase(BaseModel):
    name: str

class CategoryCreate(CategoryBase):
    pass

class CategoryResponse(CategoryBase):
    id: UUID 

    class Config:
        from_attributes = True
