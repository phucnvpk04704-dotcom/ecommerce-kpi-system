from datetime import datetime, timezone
from pydantic import Field
from app.models.base import MongoBaseModel, PyObjectId
from app.core.enums.platform import Platform
from app.core.enums.product_activity import ProductActivityType


class ProductActivity(MongoBaseModel):
    employee_id: PyObjectId = Field(...)
    platform: Platform = Field(...)
    product_id: str = Field(...)
    activity_type: ProductActivityType = Field(...)
    timestamp: datetime = Field(...)
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
