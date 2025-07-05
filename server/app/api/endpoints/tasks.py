from typing import List, Set

from fastapi import APIRouter, Depends, HTTPException, WebSocket, WebSocketDisconnect
from sqlalchemy.orm import Session

from ..models.task import TaskCreate, TaskUpdate, TaskResponse
from ...core.security import get_user_by_token
from ...db.database import get_db
from ...db.db_structure import Task, User

router = APIRouter()

active_connections: Set[WebSocket] = set()
def get_current_user():
# def get_current_user(token: str = None, db: AsyncSession = Depends(get_db)):
     return User(id="33432faf-ddbd-4b50-bd38-33bdb7d6d990", email="test@example.com", 
     hashed_password="123456", name="tduong", is_active=True,created_at="2025-02-28T09:25:49.164693")

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
def create_task(task: TaskCreate, db: Session = Depends(get_db), username: str = Depends(get_user_by_token)):
    user = db.query(User).filter(User.username == username).first()
    db_task = Task(**task.dict(), owner_id=user.id)
    db.add(db_task)
    db.commit()
    db.refresh(db_task)
    for connection in active_connections:
        connection.send_text(f"New task created: {db_task.title}")
    return db_task
# @router.post("/")
# def create_task(task: TaskCreate, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
#     print("Current user:", current_user)
#     if not current_user:
#         raise HTTPException(status_code=401, detail="Unauthorized")

#     new_task = TaskCreate(
#         # id=uuid.uuid4(),
#         title=task.title,
#         category_id = task.category_id,
#         # description=task.description,
#         # due_date=task.due_date, 
#         # time=task.time,
#         # user_id=current_user.id
#         # user_id="33432faf-ddbd-4b50-bd38-33bdb7d6d990"
#     )
#     db.add(new_task)
#     db.commit()
#     db.refresh(new_task)
#     return new_task


@router.get("/tasks/", response_model=List[TaskResponse])
def read_tasks(skip: int = 0, limit: int = 10, db: Session = Depends(get_db)):
    tasks = db.query(Task).offset(skip).limit(limit).all()
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

@router.patch("/tasks/{task_id}", response_model=TaskResponse)
def partial_update_task(task_id: int, task_update: TaskUpdate, db: Session = Depends(get_db)):
    db_task = db.query(Task).filter(Task.id == task_id).first()
    if db_task is None:
        raise HTTPException(status_code=404, detail="Task not found")
    update_data = task_update.dict(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_task, key, value)
    db.commit()
    db.refresh(db_task)
    return db_task



@router.delete("/tasks/{task_id}", response_model=TaskResponse)
def delete_task(task_id: int, db: Session = Depends(get_db)):
    task = db.query(Task).filter(Task.id == task_id).first()
    if task is None:
        raise HTTPException(status_code=404, detail="Task not found")
    db.delete(task)
    db.commit()
    for connection in active_connections:
        connection.send_text(f"Task {task.id} deleted")
    return task
