# # from sqlalchemy import create_engine
# # from sqlalchemy.orm import sessionmaker
# # from sqlalchemy.ext.declarative import declarative_base
# # from sqlalchemy import create_engine
# from configuration import URL_DATABASE
# # from models.category_model import CategoryModel

# from sqlalchemy.orm import declarative_base, sessionmaker
# from sqlalchemy import create_engine

# from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine

# engine = create_engine (URL_DATABASE)

# SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Base = declarative_base()

# # Khởi tạo bảng trong PostgreSQL
# def init_db():
#     Base.metadata.create_all(bind=engine)
# # def init_db():
# #     try:
# #         print("Initializing database...")
# #         Base.metadata.create_all(bind=engine)
# #     except Exception as e:
# #         print(f"Error initializing database: {e}")



from sqlalchemy.orm import declarative_base, sessionmaker
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from configuration import URL_DATABASE  # URL_DATABASE dạng async, ví dụ: "postgresql+asyncpg://user:pass@host/dbname"

# Tạo async engine
async_engine = create_async_engine(
    URL_DATABASE,
    echo=True,
)

# Tạo async session maker
async_session = sessionmaker(
    bind=async_engine,
    class_=AsyncSession,
    expire_on_commit=False
)

# Base cho models
Base = declarative_base()

# Dependency async lấy db session
async def get_db():
    async with async_session() as session:
        yield session

# Hàm tạo bảng (sync)
def init_db():
    # Vì create_all() không hỗ trợ async nên chạy sync engine tạm thời
    from sqlalchemy import create_engine
    sync_engine = create_engine(URL_DATABASE.replace("asyncpg", "psycopg2"))
    Base.metadata.create_all(bind=sync_engine)

