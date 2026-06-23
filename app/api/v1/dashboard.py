from typing import Annotated, List
from fastapi import APIRouter, Depends, status
from app.services.dashboard import DashboardService
from app.schemas.dashboard import (
    DashboardSummaryResponse,
    DashboardKPIResponse,
    RevenueChartEntry,
    OrdersChartEntry,
    RecentActivitiesResponse
)
from app.dependencies.services import get_dashboard_service
from app.dependencies.auth import require_admin
from app.models.employee import Employee

router = APIRouter(prefix="/dashboard", tags=["Dashboard"])


@router.get("/summary", response_model=DashboardSummaryResponse)
async def get_summary(
    admin_user: Annotated[Employee, Depends(require_admin())],
    dashboard_service: Annotated[DashboardService, Depends(get_dashboard_service)]
) -> DashboardSummaryResponse:
    """
    Retrieve global metrics summary.
    Admin privilege required.
    """
    return await dashboard_service.get_summary()


@router.get("/kpi", response_model=DashboardKPIResponse)
async def get_kpi(
    admin_user: Annotated[Employee, Depends(require_admin())],
    dashboard_service: Annotated[DashboardService, Depends(get_dashboard_service)]
) -> DashboardKPIResponse:
    """
    Retrieve today's performance indicators and growth statistics.
    Admin privilege required.
    """
    return await dashboard_service.get_kpi()


@router.get("/revenue-chart", response_model=List[RevenueChartEntry])
async def get_revenue_chart(
    admin_user: Annotated[Employee, Depends(require_admin())],
    dashboard_service: Annotated[DashboardService, Depends(get_dashboard_service)]
) -> List[RevenueChartEntry]:
    """
    Retrieve daily revenue analytics for the last 30 days.
    Admin privilege required.
    """
    return await dashboard_service.get_revenue_chart()


@router.get("/orders-chart", response_model=List[OrdersChartEntry])
async def get_orders_chart(
    admin_user: Annotated[Employee, Depends(require_admin())],
    dashboard_service: Annotated[DashboardService, Depends(get_dashboard_service)]
) -> List[OrdersChartEntry]:
    """
    Retrieve daily order count analytics for the last 30 days.
    Admin privilege required.
    """
    return await dashboard_service.get_orders_chart()


@router.get("/recent-activities", response_model=RecentActivitiesResponse)
async def get_recent_activities(
    admin_user: Annotated[Employee, Depends(require_admin())],
    dashboard_service: Annotated[DashboardService, Depends(get_dashboard_service)]
) -> RecentActivitiesResponse:
    """
    Retrieve merged recent activity feeds from multiple modules.
    Admin privilege required.
    """
    return await dashboard_service.get_recent_activities()
