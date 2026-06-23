from datetime import datetime
from decimal import Decimal
from typing import Optional
from pydantic import BaseModel, Field, ConfigDict, BeforeValidator
from typing_extensions import Annotated
from app.models.base import PyObjectId
from app.core.enums.platform import Platform
from app.core.enums.period import Period

DecimalField = Annotated[Decimal, BeforeValidator(lambda v: Decimal(str(v)) if v is not None else Decimal("0.00"))]


class RevenueBase(BaseModel):
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


class RevenueCreate(RevenueBase):
    pass


class RevenueUpdate(BaseModel):
    employee_id: Optional[PyObjectId] = Field(default=None)
    platform: Optional[Platform] = Field(default=None)
    date: Optional[datetime] = Field(default=None)
    period: Optional[Period] = Field(default=None)
    total_orders: Optional[int] = Field(default=None, ge=0)
    successful_orders: Optional[int] = Field(default=None, ge=0)
    returned_orders: Optional[int] = Field(default=None, ge=0)
    cancelled_orders: Optional[int] = Field(default=None, ge=0)
    total_revenue: Optional[DecimalField] = Field(default=None, ge=Decimal("0.00"))
    target_revenue: Optional[DecimalField] = Field(default=None, ge=Decimal("0.00"))


class RevenueResponse(RevenueBase):
    id: PyObjectId = Field(...)
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(
        from_attributes=True,
        populate_by_name=True
    )
