from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field, ConfigDict
from app.models.base import PyObjectId
from app.core.enums.platform import Platform
from app.core.enums.product_activity import ProductActivityType


class ProductActivityBase(BaseModel):
    employee_id: PyObjectId = Field(...)
    platform: Platform = Field(...)
    product_id: str = Field(...)
    activity_type: ProductActivityType = Field(...)
    timestamp: datetime = Field(...)


class ProductActivityCreate(ProductActivityBase):
    pass


class ProductActivityUpdate(BaseModel):
    employee_id: Optional[PyObjectId] = Field(default=None)
    platform: Optional[Platform] = Field(default=None)
    product_id: Optional[str] = Field(default=None)
    activity_type: Optional[ProductActivityType] = Field(default=None)
    timestamp: Optional[datetime] = Field(default=None)


class ProductActivityResponse(ProductActivityBase):
    id: PyObjectId = Field(...)
    created_at: datetime

    model_config = ConfigDict(
        from_attributes=True,
        populate_by_name=True
    )
