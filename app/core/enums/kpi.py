from enum import Enum


class KPIClassification(str, Enum):
    EXCELLENT = "Excellent"
    GOOD = "Good"
    FAIR = "Fair"
    PASS = "Pass"
    FAILED = "Failed"
