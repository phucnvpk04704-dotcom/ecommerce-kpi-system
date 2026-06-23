from datetime import datetime, timezone
from pydantic import Field
from app.models.base import MongoBaseModel, PyObjectId
from app.core.enums.kpi import KPIClassification


class KPIDaily(MongoBaseModel):
    employee_id: PyObjectId = Field(...)
    date: datetime = Field(...)
    orders_score: float = Field(..., ge=0.0, le=40.0)
    chats_score: float = Field(..., ge=0.0, le=20.0)
    products_score: float = Field(..., ge=0.0, le=15.0)
    revenue_score: float = Field(..., ge=0.0, le=25.0)
    penalty_deductions: float = Field(..., ge=0.0)
    total_kpi_score: float = Field(..., ge=0.0, le=100.0)
    classification: KPIClassification = Field(...)
    details: dict = Field(default_factory=dict)
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
