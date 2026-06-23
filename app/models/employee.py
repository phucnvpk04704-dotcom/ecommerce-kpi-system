from typing import List
from pydantic import Field, EmailStr
from app.models.base import TimestampedMongoModel
from app.core.enums.employee import Role, EmployeeStatus
from app.core.enums.platform import Platform


class Employee(TimestampedMongoModel):
    employee_code: str = Field(..., min_length=2, max_length=20)
    username: str = Field(..., min_length=3, max_length=50)
    hashed_password: str = Field(...)
    full_name: str = Field(..., min_length=2, max_length=100)
    email: EmailStr = Field(...)
    role: Role = Field(default=Role.EMPLOYEE)
    status: EmployeeStatus = Field(default=EmployeeStatus.ACTIVE)
    platforms: List[Platform] = Field(default_factory=list)
