import os
from fastapi import FastAPI, Depends, Request
from fastapi.responses import JSONResponse

from app.api.endpoints import tasks, users, categories, chat, report
from app.api.middleware.middleware import AuthMiddleware, logging_middleware, logger
from app.core.security import get_user_by_token
from app.db.database import Base, engine
from fastapi.middleware.cors import CORSMiddleware
from starlette.middleware.sessions import SessionMiddleware
from app.db.database import init_models
from fastapi.responses import JSONResponse 
from dotenv import load_dotenv

# 🔹 Load biến môi trường từ file .env
load_dotenv()

# 🔹 Lấy SECRET_KEY
SECRET_KEY = os.getenv("SECRET_KEY")

if not SECRET_KEY:
    raise ValueError("❌ SECRET_KEY not found in .env file!")
app = FastAPI()

# 🔹 1. AuthMiddleware - ĐẶT TRƯỚC TIÊN (sẽ chạy SAU CÙNG)
app.add_middleware(AuthMiddleware)

# 🔹 2. CORSMiddleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:52322",
        "http://127.0.0.1:52322",
        "http://10.121.205.30:52322"
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 🔹 3. SessionMiddleware - ĐẶT CUỐI CÙNG (sẽ chạy TRƯỚC TIÊN)
app.add_middleware(
    SessionMiddleware,
    secret_key=SECRET_KEY,
    session_cookie="sessionid",
    max_age=1209600,
    same_site="lax",
    https_only=False,
)

# # 🔹 1. SessionMiddleware - ĐẶT TRƯỚC TIÊN
# app.add_middleware(
#     SessionMiddleware,
#     secret_key= SECRET_KEY,
#     session_cookie="sessionid",
#     max_age=1209600,  # 14 days
#     same_site="lax",  # ⭐ "lax" cho HTTP, "none" cho HTTPS
#     https_only=False,  # False vì đang dùng HTTP
# )

# # 🔹 2. CORSMiddleware
# app.add_middleware(
#     CORSMiddleware,
#     allow_origins=[
#         "http://localhost:52322",
#         "http://127.0.0.1:52322",
#         "http://10.121.205.30:52322"  # IP của máy tính
#     ],
#     allow_credentials=True,  # ⭐ BẮT BUỘC để gửi cookie
#     allow_methods=["*"],
#     allow_headers=["*"],
# )

# # 🔹 3. AuthMiddleware - cuối cùng
# app.add_middleware(AuthMiddleware)

app.include_router(tasks.router, prefix="/api/v1", tags=["Tasks"])
app.include_router(users.router, prefix="/api/v1", tags=["Users"])
app.include_router(categories.router, prefix="/api/v1", tags=["Categories"])
app.include_router(chat.router, prefix="/api/v1", tags=["Chat"])
app.include_router(report.router, prefix="/api/v1", tags=["Report"])

# app.middleware("http")(logging_middleware)


# @app.on_event("startup")
# def startup_db():
#     Base.metadata.create_all(bind=engine)
@app.on_event("startup")
async def on_startup():
    await init_models()


@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    logger.exception("Alarm! Global exception!")
    return JSONResponse(
        status_code=500,
        content={"error": "O-o-o-ps! Internal server error"}
    )


@app.get("/")
def read_root():
    return {"message": "Welcome to the Real-Time Task Manager API"}


if __name__ == "__main__":
    import uvicorn

    # uvicorn.run(app, host="127.0.0.1", port=8000)
    uvicorn.run(app, host="0.0.0.0", port=8000)

@app.post("/save-data")
async def save_data(request: Request, data: dict):
    user_id = data.get("user_id")
    if not user_id:
        return {"error": "user_id is required"}
    
    # Lưu dữ liệu trong session theo user_id
    request.session[user_id] = data.get("value", {})
    
    return {"status": "saved", "session": request.session}

@app.get("/check-data/{user_id}")
async def check_data(user_id: str, request: Request):
    data = request.session.get(user_id)
    if data:
        return {"exists": True, "data": data}
    return {"exists": False}
