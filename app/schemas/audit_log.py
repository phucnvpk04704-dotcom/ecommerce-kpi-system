from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field, ConfigDict
from app.models.base import PyObjectId
from app.core.enums.audit import AuditAction


class AuditLogCreate(BaseModel):
    user_id: PyObjectId = Field(...)
    action: AuditAction = Field(...)
    entity_type: str = Field(...)
    entity_id: str = Field(...)
    old_value: Optional[dict] = Field(default=None)
    new_value: Optional[dict] = Field(default=None)


class AuditLogResponse(BaseModel):
    id: PyObjectId = Field(...)
    user_id: PyObjectId = Field(...)
    action: AuditAction = Field(...)
    entity_type: str = Field(...)
    entity_id: str = Field(...)
    old_value: Optional[dict] = Field(default=None)
    new_value: Optional[dict] = Field(default=None)
    created_at: datetime = Field(...)

    model_config = ConfigDict(
        from_attributes=True,
        populate_by_name=True
    )
