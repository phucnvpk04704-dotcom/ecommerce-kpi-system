from pydantic import Field
from app.models.base import TimestampedMongoModel, PyObjectId


class Setting(TimestampedMongoModel):
    key: str = Field(..., min_length=1, max_length=100)
    value: dict = Field(default_factory=dict)
    updated_by: PyObjectId = Field(...)
