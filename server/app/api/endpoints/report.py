from typing import List, Optional, Set

from fastapi import APIRouter, Depends, HTTPException, WebSocket, WebSocketDisconnect, Query
from app.core.session import get_current_user
from sqlalchemy.orm import Session
from ..models.task import TaskCreate, TaskUpdate, TaskResponse
from ...db.database import get_db
from ...db.db_structure import Category, Task, User
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, text, func, cast, Date
from fastapi import Query
from datetime import date, datetime, timezone, timedelta
from calendar import monthrange
router = APIRouter()


active_connections: Set[WebSocket] = set()

# @router.get("/tasks/completed-per-day/")
# async def get_completed_per_day(db: AsyncSession = Depends(get_db)):
#     result = await db.execute(
#         text("""
#             SELECT DATE(completed_at) AS day, COUNT(*) AS completed_tasks
#             FROM task
#             WHERE completed = TRUE
#             GROUP BY DATE(completed_at)
#             ORDER BY day
#         """)
#     )
#     rows = result.fetchall()
#     return [{"day": str(r.day), "completed": r.completed_tasks} for r in rows]

# @router.get("/tasks/completed-today/")
# async def get_completed_today(db: AsyncSession = Depends(get_db)):
#     result = await db.execute(
#         text("""
#             SELECT DATE(completed_at) AS day, COUNT(*) AS completed_tasks
#             FROM task
#             WHERE completed = TRUE
#               AND DATE(completed_at) = CURRENT_DATE
#             GROUP BY DATE(completed_at)
#             ORDER BY day
#         """)
#     )
#     row = result.fetchone()
#     if row:
#         return {"day": str(row.day), "completed": row.completed_tasks}
#     return {"day": str(date.today()), "completed": 0}

# @router.get("/tasks/completed-per-week/")
# async def completed_tasks_per_week(db: AsyncSession = Depends(get_db)):
#     query = text("""
#         SELECT date_trunc('week', completed_at)::date AS week_start,
#                COUNT(*) AS completed
#         FROM task
#         WHERE completed = TRUE
#         GROUP BY week_start
#         ORDER BY week_start
#     """)
#     result = await db.execute(query)
#     rows = result.fetchall()

#     return [
#         {"week_start": str(r.week_start), "completed": r.completed}
#         for r in rows
#     ]

# @router.get("/tasks/completed-by-category/by-day/")
# async def completed_tasks_by_category_by_day(
#     day: date = Query(default=date.today(), description="Date to fetch stats for"),
#     db: AsyncSession = Depends(get_db)
# ):
#     """
#     Lấy số task hoàn thành theo category cho một ngày cụ thể.
#     Nếu không truyền `day`, mặc định lấy ngày hôm nay.
#     """
#     result = await db.execute(
#         text("""
#             SELECT category_id, COUNT(*) AS completed
#             FROM task
#             WHERE completed = TRUE
#               AND DATE(completed_at) = :target_day
#             GROUP BY category_id
#             ORDER BY completed DESC
#         """),
#         {"target_day": day}  # <-- pass date object
#     )
#     rows = result.fetchall()
#     return [{"category_id": r.category_id, "completed": r.completed} for r in rows]

@router.get("/tasks/completed-by-category/by-day/")
async def completed_tasks_by_category_by_day(
    day: date,
    db: AsyncSession = Depends(get_db)
):
    """
    Trả về số task completed theo category trong ngày cụ thể,
    kèm theo tên category và màu sắc.
    """
    query = text("""
        SELECT 
        c.id as category_id,
        COALESCE(c.title, 'Unknown') as category_name,
        COALESCE(c.color, '#000000') as category_color,
        COUNT(t.id) as completed
        FROM task t
        JOIN category c ON t.category_id = c.id
        WHERE DATE(t.completed_at) = :target_day
          AND t.completed = TRUE
        GROUP BY c.id, c.title, c.color
    """)
    result = await db.execute(query, {"target_day": day})
    rows = result.fetchall()

    return [
        {
            "category_id": r.category_id,
            "name": r.category_name,
            "color": r.category_color,
            "completed": r.completed
        }
        for r in rows
    ]

@router.get("/tasks/completed-by-category/current-month/")
async def completed_tasks_by_category_current_month(db: AsyncSession = Depends(get_db)):
    today = date.today()
    start_of_month = today.replace(day=1)
    if today.month == 12:
        end_of_month = today.replace(day=31)
    else:
        next_month = today.replace(month=today.month+1, day=1)
        end_of_month = next_month - timedelta(days=1)

    result = await db.execute(
        text("""
            SELECT category_id, COUNT(*) AS completed
            FROM task
            WHERE completed = TRUE
              AND DATE(completed_at) BETWEEN :start_date AND :end_date
            GROUP BY category_id
            ORDER BY completed DESC
        """),
        {
            "start_date": start_of_month,  # <-- pass date object
            "end_date": end_of_month,      # <-- pass date object
        }
    )
    rows = result.fetchall()
    return [{"category_id": r.category_id, "completed": r.completed} for r in rows]


@router.get("/tasks/completed-per-day/current-month/")
async def get_completed_per_day_current_month(db: AsyncSession = Depends(get_db)):
    today = date.today()
    # ngày đầu tháng
    start_of_month = today.replace(day=1)
    # ngày cuối tháng
    last_day = monthrange(today.year, today.month)[1]
    end_of_month = today.replace(day=last_day)

    result = await db.execute(
        text("""
            SELECT DATE(completed_at) AS day, COUNT(*) AS completed
            FROM task
            WHERE completed = TRUE
              AND DATE(completed_at) BETWEEN :start_date AND :end_date
            GROUP BY DATE(completed_at)
            ORDER BY day
        """),
        {"start_date": start_of_month, "end_date": end_of_month}
    )
    rows = result.fetchall()

    # đảm bảo đủ số ngày trong tháng (nếu ngày nào không có task thì = 0)
    data = []
    for i in range(last_day):
        d = start_of_month + timedelta(days=i)
        found = next((r for r in rows if r.day == d), None)
        data.append({"day": str(d), "completed": found.completed if found else 0})

    return data

@router.get("/tasks/completed-per-day/current-week/")
async def get_completed_per_day_current_week(db: AsyncSession = Depends(get_db)):
    today = date.today()
    start_of_week = today - timedelta(days=today.weekday())  # Monday
    end_of_week = start_of_week + timedelta(days=6)          # Sunday

    result = await db.execute(
        text("""
            SELECT DATE(completed_at) AS day, COUNT(*) AS completed
            FROM task
            WHERE completed = TRUE
              AND DATE(completed_at) BETWEEN :start_date AND :end_date
            GROUP BY DATE(completed_at)
            ORDER BY day
        """),
        {"start_date": start_of_week, "end_date": end_of_week}
    )
    rows = result.fetchall()

    # đảm bảo đủ 7 ngày (khi không có task thì = 0)
    data = []
    for i in range(7):
        d = start_of_week + timedelta(days=i)
        found = next((r for r in rows if r.day == d), None)
        data.append({"day": str(d), "completed": found.completed if found else 0})

    return data