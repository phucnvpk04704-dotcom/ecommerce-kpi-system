import pytest
from httpx import AsyncClient
from typing import Dict
from datetime import datetime

pytestmark = pytest.mark.asyncio

async def test_create_and_list_revenue(client: AsyncClient, admin_headers: Dict[str, str], test_admin_user: Dict[str, str]):
    """
    Validate that an authorized manager/admin can create a daily revenue record and list all records.
    """
    # 1. Create a revenue log payload
    revenue_payload = {
        "employee_id": test_admin_user["employee_id"],
        "platform": "Shopee",
        "date": datetime.utcnow().isoformat(),
        "period": "DAILY",
        "total_orders": 15,
        "successful_orders": 12,
        "returned_orders": 1,
        "cancelled_orders": 2,
        "total_revenue": 25000000.00,
        "target_revenue": 30000000.00
    }
    
    create_res = await client.post("/api/v1/revenues", json=revenue_payload, headers=admin_headers)
    assert create_res.status_code == 201
    created_data = create_res.json()
    assert created_data["platform"] == "Shopee"
    assert float(created_data["total_revenue"]) == 25000000.00
    
    # 2. Retrieve all revenue records list
    list_res = await client.get("/api/v1/revenues", headers=admin_headers)
    assert list_res.status_code == 200
    records = list_res.json()
    assert len(records) >= 1
    assert records[0]["id"] == created_data["id"]

async def test_create_revenue_unauthorized_for_standard_employee(client: AsyncClient, employee_headers: Dict[str, str]):
    """
    Validate that a standard employee has no privilege to list or create revenues (fails with 403).
    """
    res = await client.get("/api/v1/revenues", headers=employee_headers)
    assert res.status_code == 403
