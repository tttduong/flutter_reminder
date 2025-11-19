from enum import Enum

class GoalStatus(str, Enum):
    pending = "pending"          # Chưa làm
    in_progress = "in_progress"  # Đang làm
    completed = "completed"      # Hoàn thành
    cancelled = "cancelled"      # Hủy bỏ
