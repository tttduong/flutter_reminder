from app.db.db_structure import Category
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession


# File utils.py dùng để chứa các hàm logic tiện ích tái sử dụng — 
# giúp xử lý các tác vụ như tạo category mặc định, validate dữ liệu, 
# hoặc hỗ trợ thao tác với database. Nó không lưu trữ dữ liệu, 
# mà chỉ giúp thực hiện logic để dữ liệu được lưu vào nơi khác 
# (thường là database).

async def get_or_create_inbox_category(db: AsyncSession, user_id: int) -> Category:
    result = await db.execute(
        select(Category).where(
            Category.title == "Inbox",
            Category.owner_id == user_id
        )
    )
    inbox = result.scalar_one_or_none()

    if inbox is None:
        inbox = Category(
        title="Inbox",
        owner_id=user_id,
        color="grey",           # hoặc giá trị mặc định khác
        icon="58040"            # hoặc bất kỳ string nào
    )
        
    db.add(inbox)
    await db.commit()
    await db.refresh(inbox)

    return inbox
