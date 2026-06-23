from datetime import datetime
from decimal import Decimal
from pydantic import BaseModel, Field, ConfigDict, BeforeValidator
from typing_extensions import Annotated
from app.models.base import PyObjectId
from app.core.enums.period import Period
from app.core.enums.reward import RewardStatus

DecimalField = Annotated[Decimal, BeforeValidator(lambda v: Decimal(str(v)) if v is not None else Decimal("0.00"))]


class RewardBase(BaseModel):
    employee_id: PyObjectId = Field(...)
    date: datetime = Field(...)
    period: Period = Field(...)
    kpi_score: float = Field(..., ge=0.0, le=100.0)
    reward_amount: DecimalField = Field(default=Decimal("0.00"), ge=Decimal("0.00"))
    currency: str = Field(default="VND")
    status: RewardStatus = Field(default=RewardStatus.PENDING)


class RewardCreate(RewardBase):
    pass


class RewardResponse(RewardBase):
    id: PyObjectId = Field(...)
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(
        from_attributes=True,
        populate_by_name=True
    )
