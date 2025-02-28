from fastapi import FastAPI, APIRouter, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from database.database import SessionLocal
from database import models, schemas

app = FastAPI()

# Dependency: Lấy database session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Cấu hình CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Cho phép tất cả domain truy cập
    allow_credentials=True,
    allow_methods=["*"],  # Cho phép tất cả method (GET, POST, PUT, DELETE, ...)
    allow_headers=["*"],  # Cho phép tất cả headers
)

router = APIRouter()

@router.get("/", response_model=list[schemas.TaskResponse])
def get_all_tasks(db: Session = Depends(get_db)):
    tasks = db.query(models.Task).filter(models.Task.is_deleted == False).all()
    return [schemas.TaskResponse.from_orm(task) for task in tasks]

@router.post("/", response_model=schemas.TaskResponse)
def create_task(new_task: schemas.TaskCreate, db: Session = Depends(get_db)):
    try:
        task = models.Task(**new_task.dict())  # Tạo object từ dữ liệu gửi lên
        db.add(task)
        db.commit()
        db.refresh(task)  # Lấy dữ liệu mới từ DB sau khi commit
        return schemas.TaskResponse.from_orm(task)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Some error occurred: {e}")



@router.put("/{task_id}", response_model=schemas.TaskResponse)
def update_task(task_id: str, updated_task: schemas.TaskCreate, db: Session = Depends(get_db)):
    task = db.query(models.Task).filter(models.Task.id == task_id, models.Task.is_deleted == False).first()
    if not task:
        raise HTTPException(status_code=404, detail="Task does not exist")

    for key, value in updated_task.dict().items():
        setattr(task, key, value)  # Cập nhật từng thuộc tính
    
    db.commit()
    db.refresh(task)
    return schemas.TaskResponse.from_orm(task)

@router.delete("/{task_id}")
def delete_task(task_id: str, db: Session = Depends(get_db)):
    task = db.query(models.Task).filter(models.Task.id == task_id, models.Task.is_deleted == False).first()
    if not task:
        raise HTTPException(status_code=404, detail="Task does not exist")

    task.is_deleted = True  # Đánh dấu là đã xóa
    db.commit()
    return {"status_code": 200, "message": "Task Deleted Successfully"}

app.include_router(router)
