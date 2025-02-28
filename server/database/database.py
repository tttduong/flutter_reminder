from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import create_engine
from configuration import URL_DATABASE

engine = create_engine (URL_DATABASE)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

# Khởi tạo bảng trong PostgreSQL
def init_db():
    Base.metadata.create_all(bind=engine)
# def init_db():
#     try:
#         print("Initializing database...")
#         Base.metadata.create_all(bind=engine)
#     except Exception as e:
#         print(f"Error initializing database: {e}")
