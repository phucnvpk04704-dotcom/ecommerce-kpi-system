from enum import Enum


class RewardStatus(str, Enum):
    PENDING = "Pending"
    APPROVED = "Approved"
    PAID = "Paid"
