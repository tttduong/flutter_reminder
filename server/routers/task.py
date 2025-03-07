from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
import jwt
from uuid import UUID
import uuid

from database.database import SessionLocal
from models.user_model import UserModel

from models.task_model import TaskModel
from schemas.task_schema import TaskCreate, TaskResponse
from routers.user import SECRET_KEY, ALGORITHM, oauth2_scheme

router = APIRouter(prefix="/tasks", tags=["Tasks"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Xác thực token
# def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    # try:
    #     payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
    #     user_id = payload.get("sub")
    #     if user_id is None:
    #         raise HTTPException(status_code=401, detail="Invalid token")
    #     return db.query(UserModel).filter(UserModel.id == user_id).first()
    # except jwt.ExpiredSignatureError:
    #     raise HTTPException(status_code=401, detail="Token expired")
    # except jwt.InvalidTokenError:
    #     raise HTTPException(status_code=401, detail="Invalid token")
def get_current_user(token: str = None, db: Session = Depends(get_db)):
     return UserModel(id="33432faf-ddbd-4b50-bd38-33bdb7d6d990", email="test@example.com", 
     hashed_password="123456", name="tduong", is_active=True,created_at="2025-02-28T09:25:49.164693")

# 1. API tạo Task
# @router.post("/", response_model=TaskResponse)
@router.post("/")

def create_task(task: TaskCreate, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    if not current_user:
        raise HTTPException(status_code=401, detail="Unauthorized")

    new_task = TaskModel(
        id=uuid.uuid4(),
        title=task.title,
        description=task.description,
        user_id=current_user.id
        # user_id="33432faf-ddbd-4b50-bd38-33bdb7d6d990"
    )
    db.add(new_task)
    db.commit()
    db.refresh(new_task)
    return new_task


@router.get("/", response_model=list[TaskResponse])
def get_all_tasks(db: Session = Depends(get_db)):
    tasks = db.query(TaskModel).filter(TaskModel.is_deleted == False).all()
    return [TaskResponse.from_orm(task) for task in tasks]

# @router.post("/", response_model=TaskResponse)
# def create_task(new_task: TaskCreate, db: Session = Depends(get_db)):
#     try:
#         task = TaskModel(**new_task.dict())  # Tạo object từ dữ liệu gửi lên
#         db.add(task)
#         db.commit()
#         db.refresh(task)  # Lấy dữ liệu mới từ DB sau khi commit
#         return TaskResponse.from_orm(task)
#     except Exception as e:
#         raise HTTPException(status_code=500, detail=f"Some error occurred: {e}")



@router.put("/{task_id}", response_model=TaskResponse)
def update_task(task_id: str, updated_task: TaskCreate, db: Session = Depends(get_db)):
    task = db.query(TaskModel).filter(TaskModel.id == task_id, TaskModel.is_deleted == False).first()
    if not task:
        raise HTTPException(status_code=404, detail="Task does not exist")

    for key, value in updated_task.dict().items():
        setattr(task, key, value)  # Cập nhật từng thuộc tính
    
    db.commit()
    db.refresh(task)
    return TaskResponse.from_orm(task)

@router.delete("/{task_id}")
def delete_task(task_id: str, db: Session = Depends(get_db)):
    task = db.query(TaskModel).filter(TaskModel.id == task_id, TaskModel.is_deleted == False).first()
    if not task:
        raise HTTPException(status_code=404, detail="Task does not exist")

    task.is_deleted = True  # Đánh dấu là đã xóa
    db.commit()
    return {"status_code": 200, "message": "Task Deleted Successfully"}


