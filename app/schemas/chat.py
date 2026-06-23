from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field, ConfigDict
from app.models.base import PyObjectId
from app.core.enums.platform import Platform


class ChatBase(BaseModel):
    employee_id: PyObjectId = Field(...)
    platform: Platform = Field(...)
    date: datetime = Field(...)
    chat_count: int = Field(..., ge=0)
    response_rate: float = Field(..., ge=0.0, le=100.0)
    avg_response_time: float = Field(..., ge=0.0)


class ChatCreate(ChatBase):
    pass


class ChatUpdate(BaseModel):
    employee_id: Optional[PyObjectId] = Field(default=None)
    platform: Optional[Platform] = Field(default=None)
    date: Optional[datetime] = Field(default=None)
    chat_count: Optional[int] = Field(default=None, ge=0)
    response_rate: Optional[float] = Field(default=None, ge=0.0, le=100.0)
    avg_response_time: Optional[float] = Field(default=None, ge=0.0)


class ChatResponse(ChatBase):
    id: PyObjectId = Field(...)
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(
        from_attributes=True,
        populate_by_name=True
    )
