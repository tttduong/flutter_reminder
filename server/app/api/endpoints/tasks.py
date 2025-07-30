from typing import List, Optional, Set

from fastapi import APIRouter, Depends, HTTPException, WebSocket, WebSocketDisconnect
from sqlalchemy.orm import Session
from app.core.security import get_current_user
from ..models.task import TaskCreate, TaskUpdate, TaskResponse
from ...core.security import get_user_by_token
from ...db.database import get_db
from ...db.db_structure import Category, Task, User
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from fastapi import Query
from datetime import date, datetime, timezone
from sqlalchemy import func, cast, Date
router = APIRouter()

active_connections: Set[WebSocket] = set()


@router.websocket("/ws/tasks/{client_id}")
async def websocket_endpoint(client_id: int, websocket: WebSocket):
    await websocket.accept()
    active_connections.add(websocket)
    try:
        while True:
            message = await websocket.receive_text()
            for connection in active_connections:
                await connection.send_text(f"Client with {client_id} wrote {message}!")
    except WebSocketDisconnect:
        active_connections.remove(websocket)


@router.post("/tasks/", response_model=TaskResponse)
async def create_task(
    task: TaskCreate, 
    db: Session = Depends(get_db), 
    current_user: User = Depends(get_current_user) 
    ):
    print(f"📝 Received task data: {task}")  
    print(f"📝 Task dict: {task.dict()}") 
    task_date = task.date if task.date else datetime.now(timezone.utc)
    new_task = Task(
    title=task.title,
    description=task.description,
    category_id= task.category_id,
    owner_id=current_user.id,
    date=task_date, 
    due_date=task.due_date
    )
    db.add(new_task)
    await db.commit()
    await db.refresh(new_task)
    return new_task

@router.get("/tasks/by-date/", response_model=List[TaskResponse])
async def get_tasks_by_date(
    date: date = Query(...),
    include_multiday: bool = Query(True),  # 👈 Cho phép filter task nhiều ngày
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    stmt = select(Task).where(
        Task.owner_id == current_user.id,
        cast(Task.date, Date) <= date,
        cast(Task.due_date, Date) >= date
        # (Task.date <= date)&(Task.due_date >= date)  # 👈 Task đang diễn ra trong ngày đó
    )
    if not include_multiday:
        # stmt = stmt.where(Task.date == Task.due_date)
        stmt = stmt.where(cast(Task.date, Date) == cast(Task.due_date, Date))
    result = await db.execute(stmt)
    return result.scalars().all()

@router.get("/tasks/by-category/", response_model=List[TaskResponse])
async def get_tasks_by_category(
    category_id: Optional[int] = Query(None),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    stmt = select(Task).where(Task.owner_id == current_user.id)

    if category_id is None:
        stmt = stmt.where(Task.category_id == None)
    else:
        stmt = stmt.where(Task.category_id == category_id)

    result = await db.execute(stmt)
    tasks = result.scalars().all()

    return tasks

@router.get("/tasks/", response_model=List[TaskResponse])
async def read_tasks(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    print(f"🔐 current_user: {current_user.id}")

    result = await db.execute(
        select(Task)
        .where(Task.owner_id == current_user.id)
    )

    tasks = result.scalars().all()
    return tasks

@router.get("/tasks/{task_id}", response_model=TaskResponse)
def read_task(task_id: int, db: Session = Depends(get_db)):
    task = db.query(Task).filter(Task.id == task_id).first()
    if task is None:
        raise HTTPException(status_code=404, detail="Task not found")
    return task



# @router.put("/tasks/{task_id}", response_model=TaskResponse)
# def update_task(task_id: int, task_update: TaskUpdate, db: Session = Depends(get_db)):
#     db_task = db.query(Task).filter(Task.id == task_id).first()
#     if db_task is None:
#         raise HTTPException(status_code=404, detail="Task not found")
#     for key, value in task_update.dict().items():
#         setattr(db_task, key, value)
#     db.commit()
#     db.refresh(db_task)
#     for connection in active_connections:
#         connection.send_text(f"Task {db_task.id} updated")
#     return db_task

@router.patch("/tasks/{task_id}/", response_model=TaskResponse)
async def partial_update_task(
    task_id: int,
    task_update: TaskUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    # 1. Tìm task theo ID và người dùng hiện tại
    result = await db.execute(
        select(Task).where(Task.id == task_id, Task.owner_id == current_user.id)
    )
    db_task = result.scalar_one_or_none()

    # 2. Không tìm thấy task
    if db_task is None:
        raise HTTPException(status_code=404, detail="Task not found")

    # 3. Cập nhật các field được truyền vào
    update_data = task_update.dict(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_task, key, value)

    # 4. Commit và trả về task mới
    await db.commit()
    await db.refresh(db_task)

    return db_task

@router.delete("/tasks/{task_id}/", response_model=TaskResponse)
async def delete_task(
    task_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    result = await db.execute(
        select(Task).where(Task.id == task_id, Task.owner_id == current_user.id)
    )
    task = result.scalars().first()

    if task is None:
        raise HTTPException(status_code=404, detail="Task not found or access denied")

    await db.delete(task)
    await db.commit()

    # Gửi thông báo WebSocket nếu có
    for connection in active_connections:
        await connection.send_text(f"Task {task.id} deleted")

    return task
