from datetime import datetime
from pydantic import Field
from app.models.base import TimestampedMongoModel, PyObjectId
from app.core.enums.platform import Platform


class Chat(TimestampedMongoModel):
    employee_id: PyObjectId = Field(...)
    platform: Platform = Field(...)
    date: datetime = Field(...)
    chat_count: int = Field(..., ge=0)
    response_rate: float = Field(..., ge=0.0, le=100.0)  # Percentage representation
    avg_response_time: float = Field(..., ge=0.0)  # Average duration in seconds
