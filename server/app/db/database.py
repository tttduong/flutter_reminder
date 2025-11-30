from typing import Optional
from fastapi import Header
# from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine, async_sessionmaker
from ..core.config import settings
from sqlalchemy.orm import DeclarativeBase
from typing import AsyncGenerator
DATABASE_URL = settings.DATABASE_URL

# engine = create_engine(DATABASE_URL)
# SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
# Base = declarative_base()


engine = create_async_engine(DATABASE_URL, echo=True)
AsyncSessionLocal = sessionmaker(
    bind=engine, class_=AsyncSession, expire_on_commit=False
)
class Base(DeclarativeBase):
    pass


async def init_models():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

async def get_db() -> AsyncGenerator[AsyncSession, None]:
    async with AsyncSessionLocal() as session:
        yield session

def optional_user(token: str = Header(default=None)) -> Optional[str]:
    try:
        # return decode_token_to_username(token)
        return "Authenticated"
    except:
        return None
