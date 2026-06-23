from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field, ConfigDict
from app.core.enums.platform import Platform
from app.core.enums.risk_level import RiskLevel


class CustomerBlacklistBase(BaseModel):
    customer_id: str = Field(...)
    platform: Platform = Field(...)
    customer_name: Optional[str] = Field(default=None)
    customer_phone: str = Field(..., min_length=7, max_length=20)
    total_orders: int = Field(default=0, ge=0)
    cancelled_orders: int = Field(default=0, ge=0)
    returned_orders: int = Field(default=0, ge=0)
    risk_score: float = Field(default=0.0, ge=0.0, le=100.0)
    risk_level: RiskLevel = Field(default=RiskLevel.LOW)
    last_order_at: Optional[datetime] = Field(default=None)


class CustomerBlacklistCreate(CustomerBlacklistBase):
    pass


class CustomerBlacklistUpdate(BaseModel):
    customer_id: Optional[str] = Field(default=None)
    platform: Optional[Platform] = Field(default=None)
    customer_name: Optional[str] = Field(default=None)
    customer_phone: Optional[str] = Field(default=None, min_length=7, max_length=20)
    total_orders: Optional[int] = Field(default=None, ge=0)
    cancelled_orders: Optional[int] = Field(default=None, ge=0)
    returned_orders: Optional[int] = Field(default=None, ge=0)
    risk_score: Optional[float] = Field(default=None, ge=0.0, le=100.0)
    risk_level: Optional[RiskLevel] = Field(default=None)
    last_order_at: Optional[datetime] = Field(default=None)


from app.models.base import PyObjectId


class CustomerBlacklistResponse(CustomerBlacklistBase):
    id: PyObjectId = Field(...)
    added_at: datetime
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(
        from_attributes=True,
        populate_by_name=True
    )
