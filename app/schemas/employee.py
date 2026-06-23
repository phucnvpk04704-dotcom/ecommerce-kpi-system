from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel, Field, EmailStr, ConfigDict
from app.core.enums.employee import Role, EmployeeStatus
from app.core.enums.platform import Platform
from app.models.base import PyObjectId


class EmployeeBase(BaseModel):
    employee_code: str = Field(..., min_length=2, max_length=20)
    username: str = Field(..., min_length=3, max_length=50)
    full_name: str = Field(..., min_length=2, max_length=100)
    email: EmailStr = Field(...)
    role: Role = Field(...)
    status: EmployeeStatus = Field(...)
    platforms: List[Platform] = Field(default_factory=list)


class EmployeeCreate(BaseModel):
    username: str = Field(..., min_length=3, max_length=50)
    full_name: str = Field(..., min_length=2, max_length=100)
    email: EmailStr = Field(...)
    password: str = Field(..., min_length=6, max_length=100)
    role: Role = Field(default=Role.EMPLOYEE)
    platforms: List[Platform] = Field(default_factory=list)


class EmployeeUpdate(BaseModel):
    full_name: Optional[str] = Field(default=None, min_length=2, max_length=100)
    email: Optional[EmailStr] = Field(default=None)
    role: Optional[Role] = Field(default=None)
    status: Optional[EmployeeStatus] = Field(default=None)
    platforms: Optional[List[Platform]] = Field(default=None)


class EmployeeResponse(EmployeeBase):
    id: PyObjectId = Field(...)
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(
        from_attributes=True,
        populate_by_name=True
    )

