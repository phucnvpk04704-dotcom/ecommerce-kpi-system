from datetime import datetime, timezone
from typing import Optional
from pydantic import Field
from app.models.base import MongoBaseModel, PyObjectId


class EmployeeSession(MongoBaseModel):
    employee_id: PyObjectId = Field(...)
    session_id: str = Field(...)
    ip_address: Optional[str] = Field(default=None)
    user_agent: Optional[str] = Field(default=None)
    last_activity_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    expires_at: datetime = Field(...)
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
