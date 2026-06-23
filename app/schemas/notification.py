from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field, ConfigDict
from app.models.base import PyObjectId
from app.core.enums.employee import Role
from app.core.enums.notification import NotificationType


class NotificationBase(BaseModel):
    recipient_role: Optional[Role] = Field(default=None)
    recipient_id: Optional[PyObjectId] = Field(default=None)
    title: str = Field(..., min_length=1, max_length=150)
    body: str = Field(..., min_length=1, max_length=1000)
    type: NotificationType = Field(default=NotificationType.SYSTEM)
    is_read: bool = Field(default=False)


class NotificationCreate(NotificationBase):
    pass


class NotificationUpdate(BaseModel):
    is_read: Optional[bool] = Field(default=None)


class NotificationResponse(NotificationBase):
    id: PyObjectId = Field(...)
    created_at: datetime

    model_config = ConfigDict(
        from_attributes=True,
        populate_by_name=True
    )
