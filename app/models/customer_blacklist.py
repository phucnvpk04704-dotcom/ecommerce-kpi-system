from datetime import datetime, timezone
from typing import Optional
from pydantic import Field
from app.models.base import TimestampedMongoModel
from app.core.enums.platform import Platform
from app.core.enums.risk_level import RiskLevel


class CustomerBlacklist(TimestampedMongoModel):
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
    added_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
