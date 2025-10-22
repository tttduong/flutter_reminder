from pydantic import BaseModel, EmailStr,  Field, validator
from typing import Optional
from app.api.models.category import CategoryOut

class UserCreate(BaseModel):
    username: str = Field(..., min_length=3, max_length=50)
    email: EmailStr
    password: str = Field(..., min_length=6)
    confirm_password: str = Field(..., min_length=6)

    @validator("confirm_password")
    def passwords_match(cls, v, values):
        if "password" in values and v != values["password"]:
            raise ValueError("Passwords do not match")
        return v

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

class LoginSchema(BaseModel):
    email: str
    password: str