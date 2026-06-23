from datetime import datetime
from decimal import Decimal
from typing import List, Optional
from pydantic import BaseModel, Field, ConfigDict, BeforeValidator
from typing_extensions import Annotated
from app.core.enums.report import ReportType, ReportSentStatus

DecimalField = Annotated[Decimal, BeforeValidator(lambda v: Decimal(str(v)) if v is not None else Decimal("0.00"))]


class ReportBase(BaseModel):
    report_type: ReportType = Field(...)
    date: datetime = Field(...)
    recipients: List[str] = Field(default_factory=list)
    total_revenue: DecimalField = Field(default=Decimal("0.00"), ge=Decimal("0.00"))
    total_orders: int = Field(default=0, ge=0)
    top_employee: Optional[str] = Field(default=None)
    new_blacklist_count: int = Field(default=0, ge=0)
    summary_data: dict = Field(default_factory=dict)
    sent_status: ReportSentStatus = Field(default=ReportSentStatus.PENDING)


class ReportCreate(ReportBase):
    pass


class ReportUpdate(BaseModel):
    sent_status: Optional[ReportSentStatus] = Field(default=None)


from app.models.base import PyObjectId


class ReportResponse(ReportBase):
    id: PyObjectId = Field(...)
    created_at: datetime

    model_config = ConfigDict(
        from_attributes=True,
        populate_by_name=True
    )
