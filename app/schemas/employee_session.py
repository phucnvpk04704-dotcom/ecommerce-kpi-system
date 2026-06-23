from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field, ConfigDict
from app.models.base import PyObjectId


class EmployeeSessionBase(BaseModel):
    employee_id: PyObjectId = Field(...)
    session_id: str = Field(...)
    ip_address: Optional[str] = Field(default=None)
    user_agent: Optional[str] = Field(default=None)
    last_activity_at: datetime = Field(...)
    expires_at: datetime = Field(...)


class EmployeeSessionCreate(EmployeeSessionBase):
    pass


class EmployeeSessionUpdate(BaseModel):
    last_activity_at: Optional[datetime] = Field(default=None)
    expires_at: Optional[datetime] = Field(default=None)


class EmployeeSessionResponse(EmployeeSessionBase):
    id: PyObjectId = Field(...)
    created_at: datetime

    model_config = ConfigDict(
        from_attributes=True,
        populate_by_name=True
    )
