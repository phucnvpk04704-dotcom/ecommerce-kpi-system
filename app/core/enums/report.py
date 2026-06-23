from enum import Enum


class ReportType(str, Enum):
    DAILY_EMAIL = "Daily_Email"
    MONTHLY_SUMMARY = "Monthly_Summary"


class ReportSentStatus(str, Enum):
    PENDING = "Pending"
    SENT = "Sent"
    FAILED = "Failed"
