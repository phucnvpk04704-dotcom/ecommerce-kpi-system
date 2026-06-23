from datetime import datetime, timezone
from typing import Optional
from pydantic import Field
from app.models.base import MongoBaseModel, PyObjectId
from app.core.enums.audit import AuditAction


class AuditLog(MongoBaseModel):
    user_id: PyObjectId = Field(...)
    action: AuditAction = Field(...)
    entity_type: str = Field(...)
    entity_id: str = Field(...)
    old_value: Optional[dict] = Field(default=None)
    new_value: Optional[dict] = Field(default=None)
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
