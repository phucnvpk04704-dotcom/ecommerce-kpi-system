import pytest
from httpx import AsyncClient
from typing import Dict

pytestmark = pytest.mark.asyncio

async def test_dashboard_summary_success(client: AsyncClient, admin_headers: Dict[str, str]):
    """
    Validate that an authenticated Admin can retrieve global dashboard summary indicators.
    """
    res = await client.get("/api/v1/dashboard/summary", headers=admin_headers)
    assert res.status_code == 200
    data = res.json()
    assert "total_revenue" in data
    assert "total_orders" in data
    assert "total_employees" in data
    assert "active_sessions" in data

async def test_dashboard_kpi_success(client: AsyncClient, admin_headers: Dict[str, str]):
    """
    Validate that an authenticated Admin can retrieve daily performance KPIs.
    """
    res = await client.get("/api/v1/dashboard/kpi", headers=admin_headers)
    assert res.status_code == 200
    data = res.json()
    assert "orders_today" in data
    assert "revenue_today" in data
    assert "active_users_today" in data
    assert "growth_rate" in data

async def test_dashboard_summary_denied_to_standard_employee(client: AsyncClient, employee_headers: Dict[str, str]):
    """
    Validate that standard employee tokens are forbidden from reading admin dashboard summary metrics (fails with 403).
    """
    res = await client.get("/api/v1/dashboard/summary", headers=employee_headers)
    assert res.status_code == 403
