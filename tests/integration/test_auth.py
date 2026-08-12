import pytest
from httpx import AsyncClient
from typing import Dict

pytestmark = pytest.mark.asyncio

async def test_login_success(client: AsyncClient, test_admin_user: Dict[str, str]):
    """
    Validate that an admin user can login with correct credentials and receive JWT credentials details.
    """
    res = await client.post("/api/v1/auth/login", json={
        "username": test_admin_user["username"],
        "password": test_admin_user["password"]
    })
    assert res.status_code == 200
    data = res.json()
    assert "access_token" in data
    assert data["token_type"] == "bearer"
    assert data["employee_id"] == test_admin_user["employee_id"]
    assert "session_id" in data

async def test_login_failure(client: AsyncClient):
    """
    Validate that invalid login attempts fail with 401 Unauthorized status.
    """
    res = await client.post("/api/v1/auth/login", json={
        "username": "nonexistentuser",
        "password": "wrongpassword"
    })
    assert res.status_code == 401
    assert "detail" in res.json()

async def test_validate_token_success(client: AsyncClient, admin_headers: Dict[str, str], test_admin_user: Dict[str, str]):
    """
    Validate that a valid JWT token passes authentication validation and returns active session data.
    """
    res = await client.get("/api/v1/auth/validate", headers=admin_headers)
    assert res.status_code == 200
    data = res.json()
    assert data["username"] == test_admin_user["username"]
    assert data["role"] == "Admin"
    assert data["employee_id"] == test_admin_user["employee_id"]

async def test_validate_token_invalid(client: AsyncClient):
    """
    Validate that invalid JWT token queries fail validation with 401 Unauthorized.
    """
    res = await client.get("/api/v1/auth/validate", headers={"Authorization": "Bearer invalidtoken"})
    assert res.status_code == 401

async def test_logout_success(client: AsyncClient, test_admin_user: Dict[str, str]):
    """
    Validate that logout invalidates the session and blocks further access.
    """
    # 1. Login to get a token and session ID
    login_res = await client.post("/api/v1/auth/login", json={
        "username": test_admin_user["username"],
        "password": test_admin_user["password"]
    })
    assert login_res.status_code == 200
    login_data = login_res.json()
    token = login_data["access_token"]
    session_id = login_data["session_id"]
    
    headers = {"Authorization": f"Bearer {token}"}
    
    # 2. Invalidate session via secure logout
    logout_res = await client.post(f"/api/v1/auth/logout?session_id={session_id}", headers=headers)
    assert logout_res.status_code == 200
    assert logout_res.json() == {"success": True}
    
    # 3. Verify that further validation requests fail since session is cleared
    val_res = await client.get("/api/v1/auth/validate", headers=headers)
    assert val_res.status_code == 401

async def test_logout_unauthorized(client: AsyncClient):
    """
    Validate that unauthenticated calls to logout are rejected with 401.
    """
    res = await client.post("/api/v1/auth/logout?session_id=arbitrarysession")
    assert res.status_code == 401

async def test_logout_forbidden_session_id_mismatch(client: AsyncClient, employee_headers: Dict[str, str]):
    """
    Validate that an authenticated employee cannot revoke a different session ID (fails with 403).
    """
    res = await client.post("/api/v1/auth/logout?session_id=differentsessionid", headers=employee_headers)
    assert res.status_code == 403
    assert "permission" in res.json()["detail"]
