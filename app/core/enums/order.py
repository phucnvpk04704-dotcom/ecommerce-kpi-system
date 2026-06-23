from enum import Enum


class OrderStatus(str, Enum):
    COMPLETED = "Completed"
    CANCELLED = "Cancelled"
    RETURNED = "Returned"
    LATE = "Late"
    PENDING = "Pending"
