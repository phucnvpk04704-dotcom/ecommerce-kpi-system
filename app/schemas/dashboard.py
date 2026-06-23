from datetime import datetime
from decimal import Decimal
from typing import List
from pydantic import BaseModel, Field
from app.models.base import PyObjectId
from app.schemas.order import OrderResponse
from app.schemas.audit_log import AuditLogResponse
from app.schemas.employee_session import EmployeeSessionResponse
from app.schemas.notification import NotificationResponse


class DashboardSummaryResponse(BaseModel):
    total_orders: int = Field(...)
    total_revenue: Decimal = Field(...)
    total_employees: int = Field(...)
    active_sessions: int = Field(...)
    total_notifications: int = Field(...)
    blacklisted_customers: int = Field(...)


class DashboardKPIResponse(BaseModel):
    orders_today: int = Field(...)
    revenue_today: Decimal = Field(...)
    active_users_today: int = Field(...)
    growth_rate: float = Field(...)


class RevenueChartEntry(BaseModel):
    date: str = Field(...)
    revenue: Decimal = Field(...)


class OrdersChartEntry(BaseModel):
    date: str = Field(...)
    order_count: int = Field(...)


class RecentActivitiesResponse(BaseModel):
    recent_orders: List[OrderResponse] = Field(...)
    recent_audit_logs: List[AuditLogResponse] = Field(...)
    recent_sessions: List[EmployeeSessionResponse] = Field(...)
    recent_notifications: List[NotificationResponse] = Field(...)
