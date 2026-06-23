from datetime import datetime, timezone
from decimal import Decimal
from typing import List, Optional
from pydantic import Field, BeforeValidator
from typing_extensions import Annotated
from app.models.base import MongoBaseModel
from app.core.enums.report import ReportType, ReportSentStatus

DecimalField = Annotated[Decimal, BeforeValidator(lambda v: Decimal(str(v)) if v is not None else Decimal("0.00"))]


class Report(MongoBaseModel):
    report_type: ReportType = Field(...)
    date: datetime = Field(...)
    recipients: List[str] = Field(default_factory=list)
    total_revenue: DecimalField = Field(default=Decimal("0.00"), ge=Decimal("0.00"))
    total_orders: int = Field(default=0, ge=0)
    top_employee: Optional[str] = Field(default=None)
    new_blacklist_count: int = Field(default=0, ge=0)
    summary_data: dict = Field(default_factory=dict)
    sent_status: ReportSentStatus = Field(default=ReportSentStatus.PENDING)
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
