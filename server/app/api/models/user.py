from pydantic import BaseModel, EmailStr
from typing import Optional

from app.api.models.category import CategoryOut

class UserCreate(BaseModel):
    username: str
    email: EmailStr = None
    password: str


class UserResponse(BaseModel):
    id: int
    username: str
    email: str






class UserOut(BaseModel):
    id: int
    email: str
    username: str
    
    class Config:
        from_attributes = True

class UserResponse(BaseModel):
    user: UserOut
    default_category: Optional[CategoryOut] = None
    
    class Config:
        from_attributes = True

class LoginResponse(BaseModel):
    access_token: str
    token_type: str
    user: UserOut
    default_category: Optional[CategoryOut] = None
    
    class Config:
        from_attributes = True