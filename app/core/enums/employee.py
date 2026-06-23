from enum import Enum


class Role(str, Enum):
    ADMIN = "Admin"
    MANAGER = "Manager"
    EMPLOYEE = "Employee"


class EmployeeStatus(str, Enum):
    ACTIVE = "Active"
    INACTIVE = "Inactive"
