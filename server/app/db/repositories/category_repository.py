from app.db.db_structure import Category, Task
from sqlalchemy import func, select, case
from sqlalchemy.ext.asyncio import AsyncSession

# service.py hoặc repository.py
async def fetch_categories_with_stats(db: AsyncSession, owner_id: int):
   

    stmt = (
        select(
            Category.id,
            Category.title,
            Category.color,
            Category.icon,
            Category.is_default,
            Category.owner_id,
            func.count(Task.id).label("total_count"),
            func.sum(
                case((Task.completed == True, 1), else_=0)
            ).label("completed_count")
        )
        .outerjoin(Task)
        .where(Category.owner_id == owner_id)
        .group_by(Category.id)
    )

    result = await db.execute(stmt)
    categories = result.all()
    return categories
