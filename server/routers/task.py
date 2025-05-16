from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from datetime import date, datetime, time
from typing import Optional
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
import jwt
from uuid import UUID
import uuid

# from database.database import SessionLocal
from models.user_model import UserModel
from sqlalchemy.ext.asyncio import AsyncSession
from database.database import get_db  
from models.task_model import TaskModel
from schemas.task_schema import TaskCreate, TaskResponse, TaskUpdate
from routers.user import SECRET_KEY, ALGORITHM, oauth2_scheme
from sqlalchemy import select, and_
from typing import Optional


router = APIRouter(prefix="/tasks", tags=["Tasks"])

# def get_db():
#     db = SessionLocal()
#     try:
#         yield db
#     finally:
#         db.close()

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
def get_current_user(token: str = None, db: AsyncSession = Depends(get_db)):
     return UserModel(id="33432faf-ddbd-4b50-bd38-33bdb7d6d990", email="test@example.com", 
     hashed_password="123456", name="tduong", is_active=True,created_at="2025-02-28T09:25:49.164693")

# 1. API tạo Task
# @router.post("/", response_model=TaskResponse)
@router.post("/")
def create_task(task: TaskCreate, db: AsyncSession = Depends(get_db), current_user=Depends(get_current_user)):
    if not current_user:
        raise HTTPException(status_code=401, detail="Unauthorized")

    new_task = TaskModel(
        id=uuid.uuid4(),
        title=task.title,
        category_id = task.category_id,
        description=task.description,
        due_date=task.due_date, 
        time=task.time,
        user_id=current_user.id
        # user_id="33432faf-ddbd-4b50-bd38-33bdb7d6d990"
    )
    db.add(new_task)
    db.commit()
    db.refresh(new_task)
    return new_task

#get all tasks
@router.get("/", response_model=list[TaskResponse])
async def get_all_tasks(db: AsyncSession = Depends(get_db)):
    stmt = select(TaskModel).where(TaskModel.is_deleted == False)
    result = await db.execute(stmt)
    tasks = result.scalars().all()
    return [TaskResponse.from_orm(task) for task in tasks]

@router.get("/today", response_model=list[TaskResponse])
async def get_tasks_today(db: AsyncSession = Depends(get_db)):
    today = date.today()
    result = await db.execute(select(TaskModel).where(TaskModel.due_date == today))
    tasks = result.scalars().all()
    return tasks

#get all incompleted tasks by categoryid
@router.get("/by_category/{category_id}", response_model=list[TaskResponse])
def get_completed_tasks_by_category_id(category_id: str, db: AsyncSession = Depends(get_db)):
    tasks = db.query(TaskModel)\
        .filter(
            TaskModel.category_id == category_id,
            TaskModel.is_completed == False,
            TaskModel.is_deleted == False
        ).all()
    return [TaskResponse.from_orm(task) for task in tasks]

#get all completed tasks by categoryid
@router.get("/by_category", response_model=list[TaskResponse])
async def get_tasks_by_category(
    category_id: str,
    is_completed: Optional[bool] = None,
    db: AsyncSession = Depends(get_db)
):
    conditions = [
        TaskModel.category_id == category_id,
        TaskModel.is_deleted == False
    ]

    if is_completed is not None:
        conditions.append(TaskModel.is_completed == is_completed)

    stmt = select(TaskModel).where(and_(*conditions))
    result = await db.execute(stmt)
    tasks = result.scalars().all()
    
    return [TaskResponse.from_orm(task) for task in tasks]



# @router.get("/by_category/{category_id}", response_model=list[TaskResponse])
# def get_completed_tasks_by_category_id(category_id: str, db: Session = Depends(get_db)):
#     tasks = db.query(TaskModel)\
#         .filter(
#             TaskModel.category_id == category_id,
#             TaskModel.is_completed == True,
#             TaskModel.is_deleted == False
#         ).all()
#     return [TaskResponse.from_orm(task) for task in tasks]

@router.get("/by_category/{category_id}", response_model=list[TaskResponse])
async def get_tasks_by_category(category_id: UUID, db: AsyncSession = Depends(get_db)):
    tasks = db.query(TaskModel).filter(TaskModel.category_id == category_id, TaskModel.is_deleted == False).all()
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
def update_task(task_id: str, updated_task: TaskUpdate, db: AsyncSession = Depends(get_db)):
    task = db.query(TaskModel).filter(TaskModel.id == task_id, TaskModel.is_deleted == False).first()
    if not task:
        raise HTTPException(status_code=404, detail="Task does not exist")
    
    update_data = updated_task.dict(exclude_unset=True)

    for key, value in update_data.items():
        setattr(task, key, value)  # Cập nhật từng thuộc tính
    
    db.commit()
    db.refresh(task)
    return TaskResponse.from_orm(task)

@router.delete("/{task_id}")
def delete_task(task_id: str, db: AsyncSession = Depends(get_db)):
    task = db.query(TaskModel).filter(TaskModel.id == task_id, TaskModel.is_deleted == False).first()
    if not task:
        raise HTTPException(status_code=404, detail="Task does not exist")

    task.is_deleted = True  # Đánh dấu là đã xóa
    db.commit()
    return {"status_code": 200, "message": "Task Deleted Successfully"}


