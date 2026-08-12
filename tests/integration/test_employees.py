import pytest
from httpx import AsyncClient
from typing import Dict

pytestmark = pytest.mark.asyncio

async def test_employee_crud_lifecycle(client: AsyncClient, admin_headers: Dict[str, str]):
    """
    Validate that an admin can perform a complete Employee CRUD operations lifecycle.
    """
    # 1. Create a new employee profile
    new_employee_payload = {
        "username": "testerstaff",
        "password": "testerstaffpassword",
        "full_name": "Nguyen Van Tester",
        "email": "testerstaff@ecommerce.com",
        "role": "Employee",
        "platforms": ["Shopee", "Lazada"]
    }
    
    create_res = await client.post("/api/v1/employees", json=new_employee_payload, headers=admin_headers)
    assert create_res.status_code == 201
    employee_data = create_res.json()
    assert employee_data["username"] == "testerstaff"
    assert "employee_code" in employee_data
    employee_id = employee_data["id"]
    
    # 2. Retrieve the employee profile details by ID
    get_res = await client.get(f"/api/v1/employees/{employee_id}", headers=admin_headers)
    assert get_res.status_code == 200
    assert get_res.json()["full_name"] == "Nguyen Van Tester"
    
    # 3. Update the employee profile fields
    update_payload = {
        "full_name": "Nguyen Van Tester Updated",
        "email": "tester.updated@ecommerce.com",
        "platforms": ["Shopee"]
    }
    update_res = await client.put(f"/api/v1/employees/{employee_id}", json=update_payload, headers=admin_headers)
    assert update_res.status_code == 200
    assert update_res.json()["full_name"] == "Nguyen Van Tester Updated"
    assert update_res.json()["email"] == "tester.updated@ecommerce.com"
    assert update_res.json()["platforms"] == ["Shopee"]
    
    # 4. Soft-deactivate/delete the employee profile
    delete_res = await client.delete(f"/api/v1/employees/{employee_id}", headers=admin_headers)
    assert delete_res.status_code == 200
    assert delete_res.json()["status"] == "Inactive"
    
    # 5. Verify they are soft-deactivated (status inactive) in direct query
    check_res = await client.get(f"/api/v1/employees/{employee_id}", headers=admin_headers)
    assert check_res.json()["status"] == "Inactive"

async def test_employee_creation_denied_to_non_admin(client: AsyncClient, employee_headers: Dict[str, str]):
    """
    Validate that non-admin (e.g. employee role) requests to create profiles are blocked with 403 Forbidden.
    """
    payload = {
        "username": "unauthorizeduser",
        "password": "somepassword123",
        "full_name": "Unauthorized Attempt",
        "email": "unauth@ecommerce.com",
        "role": "Employee",
        "platforms": ["Shopee"]
    }
    res = await client.post("/api/v1/employees", json=payload, headers=employee_headers)
    assert res.status_code == 403
    assert "privilege" in res.json()["detail"].lower()
