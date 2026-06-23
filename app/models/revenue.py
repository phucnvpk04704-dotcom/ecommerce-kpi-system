from datetime import datetime
from decimal import Decimal
from pydantic import Field, BeforeValidator
from typing_extensions import Annotated
from app.models.base import TimestampedMongoModel, PyObjectId
from app.core.enums.platform import Platform
from app.core.enums.period import Period

DecimalField = Annotated[Decimal, BeforeValidator(lambda v: Decimal(str(v)) if v is not None else Decimal("0.00"))]


class Revenue(TimestampedMongoModel):
    employee_id: PyObjectId = Field(...)
    platform: Platform = Field(...)
    date: datetime = Field(...)
    period: Period = Field(...)
    total_orders: int = Field(default=0, ge=0)
    successful_orders: int = Field(default=0, ge=0)
    returned_orders: int = Field(default=0, ge=0)
    cancelled_orders: int = Field(default=0, ge=0)
    total_revenue: DecimalField = Field(default=Decimal("0.00"), ge=Decimal("0.00"))
    target_revenue: DecimalField = Field(default=Decimal("0.00"), ge=Decimal("0.00"))
