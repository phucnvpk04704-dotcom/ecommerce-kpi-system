import pytest
from httpx import AsyncClient
from typing import Dict

pytestmark = pytest.mark.asyncio

async def test_blacklist_crud_and_lookup(client: AsyncClient, admin_headers: Dict[str, str]):
    """
    Validate that an admin can add a customer to the blacklist and query them by phone.
    """
    # 1. Create a blacklist record payload
    blacklist_payload = {
        "customer_id": "cust12345",
        "platform": "Shopee",
        "customer_name": "Nguyen Van Scam",
        "customer_phone": "0988777666",
        "total_orders": 10,
        "cancelled_orders": 4,
        "returned_orders": 2,
        "risk_score": 40.0,
        "risk_level": "Medium"
    }
    
    create_res = await client.post("/api/v1/customer_blacklist", json=blacklist_payload, headers=admin_headers)
    assert create_res.status_code == 201
    created_data = create_res.json()
    assert created_data["customer_name"] == "Nguyen Van Scam"
    
    # 2. Look up customer blacklist profile by phone number
    lookup_res = await client.get("/api/v1/customer_blacklist/phone/0988777666", headers=admin_headers)
    assert lookup_res.status_code == 200
    assert lookup_res.json()["customer_id"] == "cust12345"

async def test_blacklist_evaluate_risk(client: AsyncClient, admin_headers: Dict[str, str]):
    """
    Validate that triggering a blacklist risk evaluation recalculates score claims.
    """
    # 1. Register customer in the blacklist first
    blacklist_payload = {
        "customer_id": "cust999",
        "platform": "Shopee",
        "customer_name": "Test Evaluated Customer",
        "customer_phone": "0911222333",
        "total_orders": 0,
        "cancelled_orders": 0,
        "returned_orders": 0,
        "risk_score": 0.0,
        "risk_level": "Low"
    }
    await client.post("/api/v1/customer_blacklist", json=blacklist_payload, headers=admin_headers)
    
    # 2. Call evaluate risk endpoint which aggregates from orders (will yield 0 orders/0 risk since test orders collection is clear)
    evaluate_payload = {
        "customer_id": "cust999",
        "customer_phone": "0911222333",
        "platform": "Shopee"
    }
    res = await client.post("/api/v1/customer_blacklist/evaluate", json=evaluate_payload, headers=admin_headers)
    assert res.status_code == 200
    data = res.json()
    assert data["customer_id"] == "cust999"
    assert data["risk_score"] == 0.0
    assert data["risk_level"] == "Low"

async def test_blacklist_unauthorized_for_standard_employee(client: AsyncClient, employee_headers: Dict[str, str]):
    """
    Validate that employee-level access tokens are forbidden from querying blacklist phone lookup (fails with 403).
    """
    res = await client.get("/api/v1/customer_blacklist/phone/0988777666", headers=employee_headers)
    assert res.status_code == 403
