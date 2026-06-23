from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field, ConfigDict
from app.models.base import PyObjectId


class SettingBase(BaseModel):
    key: str = Field(..., min_length=1, max_length=100)
    value: dict = Field(default_factory=dict)
    updated_by: PyObjectId = Field(...)


class SettingCreate(SettingBase):
    pass


class SettingUpdate(BaseModel):
    value: Optional[dict] = Field(default=None)
    updated_by: Optional[PyObjectId] = Field(default=None)


class SettingResponse(SettingBase):
    id: PyObjectId = Field(...)
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(
        from_attributes=True,
        populate_by_name=True
    )
