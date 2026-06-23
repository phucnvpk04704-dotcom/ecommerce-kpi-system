from datetime import datetime
from decimal import Decimal
from typing import Optional
from pydantic import Field, BeforeValidator
from typing_extensions import Annotated
from app.models.base import TimestampedMongoModel, PyObjectId
from app.core.enums.platform import Platform
from app.core.enums.order import OrderStatus

# Custom Decimal validator to convert float/str/Decimal128 cleanly to Python Decimal
DecimalField = Annotated[Decimal, BeforeValidator(lambda v: Decimal(str(v)) if v is not None else Decimal("0.00"))]


class Order(TimestampedMongoModel):
    order_id: str = Field(..., min_length=2, max_length=50)
    platform: Platform = Field(...)
    customer_id: str = Field(...)
    customer_name: Optional[str] = Field(default=None)
    customer_phone: str = Field(...)
    confirmed_by: PyObjectId = Field(...)
    total_amount: DecimalField = Field(default=Decimal("0.00"), ge=Decimal("0.00"))
    status: OrderStatus = Field(default=OrderStatus.PENDING)
    cancel_reason: Optional[str] = Field(default=None)
    return_reason: Optional[str] = Field(default=None)
    confirmed_at: Optional[datetime] = Field(default=None)
    completed_at: Optional[datetime] = Field(default=None)
    cancelled_at: Optional[datetime] = Field(default=None)
    returned_at: Optional[datetime] = Field(default=None)
    late_at: Optional[datetime] = Field(default=None)
