from enum import Enum


class NotificationType(str, Enum):
    KPI_ALERT = "KPI_Alert"
    BLACKLIST_ALERT = "Blacklist_Alert"
    SYSTEM = "System"
