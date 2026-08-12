from datetime import datetime
from pydantic import BaseModel, Field, ConfigDict
from app.models.base import PyObjectId
from app.core.enums.kpi import KPIClassification


class KPIDailyBase(BaseModel):
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


class KPIDailyCreate(KPIDailyBase):
    pass


class KPIDailyResponse(KPIDailyBase):
    id: PyObjectId = Field(...)
    created_at: datetime

    model_config = ConfigDict(
        from_attributes=True,
        populate_by_name=True
    )


class KPIAggregationResponse(BaseModel):
    orders_score: float
    chats_score: float
    products_score: float
    revenue_score: float
    penalty_deductions: float
    total_kpi_score: float
    count: int

