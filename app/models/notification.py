from datetime import datetime, timezone
from typing import Optional
from pydantic import Field
from app.models.base import MongoBaseModel, PyObjectId
from app.core.enums.employee import Role
from app.core.enums.notification import NotificationType


class Notification(MongoBaseModel):
    recipient_role: Optional[Role] = Field(default=None)
    recipient_id: Optional[PyObjectId] = Field(default=None)
    title: str = Field(..., min_length=1, max_length=150)
    body: str = Field(..., min_length=1, max_length=1000)
    type: NotificationType = Field(default=NotificationType.SYSTEM)
    is_read: bool = Field(default=False)
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
