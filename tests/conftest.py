import os
import sys
import pytest
from httpx import AsyncClient
from typing import AsyncGenerator, Dict

# 1. Override environment variables to isolate database and configurations
os.environ["DATABASE_NAME"] = "ecommerce_kpi_test_db"
os.environ["JWT_SECRET_KEY"] = "test-secret-key-must-be-long-enough-and-random-32-bytes"
os.environ["DEBUG"] = "true"

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# =====================================================================
# MONKEYPATCH DATABASE CLIENT FOR LOOP ISOLATION IN TESTS
# =====================================================================
import app.db.client
from motor.motor_asyncio import AsyncIOMotorClient
from app.core.config import settings

import asyncio
from decimal import Decimal
from bson.codec_options import TypeCodec, TypeRegistry, CodecOptions
from bson.decimal128 import Decimal128

class DecimalCodec(TypeCodec):
    python_type = Decimal
    bson_type = Decimal128

    def transform_python(self, value):
        return Decimal128(value)

    def transform_bson(self, value):
        return value.to_decimal()

TEST_CODEC_OPTIONS = CodecOptions(type_registry=TypeRegistry([DecimalCodec()]))

_active_test_db = None

def get_loop_safe_database():
    """
    Loop-safe database resolver that returns the active test database client
    initialized on the main test loop, preventing worker thread loop mismatches.
    """
    global _active_test_db
    if _active_test_db is not None:
        app.db.client.MongoClientManager.db = _active_test_db
        app.db.client.MongoClientManager.client = _active_test_db.client
        return _active_test_db
    
    # Fallback to standard manager if not inside active setup_db test fixture context
    if app.db.client.MongoClientManager.db is None:
        client_inst = AsyncIOMotorClient(settings.MONGODB_URL)
        app.db.client.MongoClientManager.client = client_inst
        app.db.client.MongoClientManager.db = client_inst.get_database(settings.DATABASE_NAME, codec_options=TEST_CODEC_OPTIONS)
    return app.db.client.MongoClientManager.db

def mock_connect_to_database():
    """Mock connection function to redirect lifecycle boots to the safe database resolver."""
    get_loop_safe_database()

# Apply the monkeypatch to app.db.client BEFORE importing app.main
app.db.client.get_database = get_loop_safe_database
app.db.client.MongoClientManager.connect_to_database = mock_connect_to_database

import app.dependencies.db
app.dependencies.db.get_database = get_loop_safe_database

# =====================================================================

# 2. Now import application components
from app.main import app as fastapi_app
from app.db.client import MongoClientManager
from app.db.indexes import ensure_indexes
from app.core.security import get_password_hash
from app.core.enums.employee import Role, EmployeeStatus
from app.core.enums.platform import Platform

# Overrides for database and repositories to force async execution on the main loop
from app.dependencies.services import (
    get_employee_repository,
    get_employee_session_repository,
    get_order_repository,
    get_chat_repository,
    get_product_activity_repository,
    get_revenue_repository,
    get_kpi_repository,
    get_reward_repository,
    get_customer_blacklist_repository,
    get_notification_repository,
    get_report_repository,
    get_setting_repository,
    get_audit_log_repository,
)
from app.dependencies.db import get_database

from app.repositories.employee import EmployeeRepository
from app.repositories.employee_session import EmployeeSessionRepository
from app.repositories.order import OrderRepository
from app.repositories.chat import ChatRepository
from app.repositories.product_activity import ProductActivityRepository
from app.repositories.revenue import RevenueRepository
from app.repositories.kpi import KPIDailyRepository
from app.repositories.reward import RewardRepository
from app.repositories.customer_blacklist import CustomerBlacklistRepository
from app.repositories.notification import NotificationRepository
from app.repositories.report import ReportRepository
from app.repositories.setting import SettingRepository
from app.repositories.audit_log import AuditLogRepository

async def override_get_database():
    return get_loop_safe_database()

async def override_get_employee_repository():
    db = get_loop_safe_database()
    return EmployeeRepository(db["employees"])

async def override_get_employee_session_repository():
    db = get_loop_safe_database()
    return EmployeeSessionRepository(db["employee_sessions"])

async def override_get_order_repository():
    db = get_loop_safe_database()
    return OrderRepository(db["orders"])

async def override_get_chat_repository():
    db = get_loop_safe_database()
    return ChatRepository(db["chats"])

async def override_get_product_activity_repository():
    db = get_loop_safe_database()
    return ProductActivityRepository(db["product_activities"])

async def override_get_revenue_repository():
    db = get_loop_safe_database()
    return RevenueRepository(db["revenues"])

async def override_get_kpi_repository():
    db = get_loop_safe_database()
    return KPIDailyRepository(db["kpi_daily"])

async def override_get_reward_repository():
    db = get_loop_safe_database()
    return RewardRepository(db["rewards"])

async def override_get_customer_blacklist_repository():
    db = get_loop_safe_database()
    return CustomerBlacklistRepository(db["customer_blacklist"])

async def override_get_notification_repository():
    db = get_loop_safe_database()
    return NotificationRepository(db["notifications"])

async def override_get_report_repository():
    db = get_loop_safe_database()
    return ReportRepository(db["reports"])

async def override_get_setting_repository():
    db = get_loop_safe_database()
    return SettingRepository(db["settings"])

async def override_get_audit_log_repository():
    db = get_loop_safe_database()
    return AuditLogRepository(db["audit_logs"])

fastapi_app.dependency_overrides[get_database] = override_get_database
fastapi_app.dependency_overrides[get_employee_repository] = override_get_employee_repository
fastapi_app.dependency_overrides[get_employee_session_repository] = override_get_employee_session_repository
fastapi_app.dependency_overrides[get_order_repository] = override_get_order_repository
fastapi_app.dependency_overrides[get_chat_repository] = override_get_chat_repository
fastapi_app.dependency_overrides[get_product_activity_repository] = override_get_product_activity_repository
fastapi_app.dependency_overrides[get_revenue_repository] = override_get_revenue_repository
fastapi_app.dependency_overrides[get_kpi_repository] = override_get_kpi_repository
fastapi_app.dependency_overrides[get_reward_repository] = override_get_reward_repository
fastapi_app.dependency_overrides[get_customer_blacklist_repository] = override_get_customer_blacklist_repository
fastapi_app.dependency_overrides[get_notification_repository] = override_get_notification_repository
fastapi_app.dependency_overrides[get_report_repository] = override_get_report_repository
fastapi_app.dependency_overrides[get_setting_repository] = override_get_setting_repository
fastapi_app.dependency_overrides[get_audit_log_repository] = override_get_audit_log_repository


class TestEventLoopPolicy(asyncio.DefaultEventLoopPolicy):
    def __init__(self, loop):
        super().__init__()
        self._loop = loop

    def get_event_loop(self):
        return self._loop

@pytest.fixture(scope="function", autouse=True)
async def setup_db():
    """
    Function-scoped database fixture that drops the test database,
    boots up connection lifecycle, and ensures indexes are established.
    """
    global _active_test_db
    loop = asyncio.get_running_loop()

    # Set custom event loop policy to redirect all threads to the test loop
    old_policy = asyncio.get_event_loop_policy()
    asyncio.set_event_loop_policy(TestEventLoopPolicy(loop))

    # Force creation of client on the current test event loop
    client_inst = AsyncIOMotorClient(settings.MONGODB_URL)
    _active_test_db = client_inst.get_database(settings.DATABASE_NAME, codec_options=TEST_CODEC_OPTIONS)
    
    # Crucial: populate manager properties before ensuring indexes
    MongoClientManager.client = client_inst
    MongoClientManager.db = _active_test_db
    
    # Drop previous test runs data
    await client_inst.drop_database("ecommerce_kpi_test_db")
    
    # Ensure indexes are built
    await ensure_indexes()
    
    yield
    
    # Cleanup database on function teardown
    if _active_test_db is not None:
        try:
            await _active_test_db.client.drop_database("ecommerce_kpi_test_db")
        except Exception:
            pass
        _active_test_db.client.close()
        
    _active_test_db = None
    MongoClientManager.client = None
    MongoClientManager.db = None
    
    # Restore original loop policy
    asyncio.set_event_loop_policy(old_policy)

@pytest.fixture(scope="function")
async def client() -> AsyncGenerator[AsyncClient, None]:
    """
    Yields an AsyncClient bound to the FastAPI app, triggering its lifespan context.
    """
    from httpx import ASGITransport
    transport = ASGITransport(app=fastapi_app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        yield ac

@pytest.fixture(scope="function")
async def test_admin_user() -> Dict[str, str]:
    """
    Seeds a test administrator user profile in the database and returns credentials.
    """
    db = get_loop_safe_database()
    admin_data = {
        "employee_code": "NV001",
        "username": "testadmin",
        "hashed_password": get_password_hash("adminsecretpwd"),
        "full_name": "Test Administrator",
        "email": "testadmin@ecommerce.com",
        "role": Role.ADMIN.value,
        "status": EmployeeStatus.ACTIVE.value,
        "platforms": [Platform.SHOPEE.value, Platform.LAZADA.value]
    }
    
    await db["employees"].delete_one({"username": "testadmin"})
    res = await db["employees"].insert_one(admin_data)
    admin_data["_id"] = str(res.inserted_id)
    
    return {
        "username": "testadmin",
        "password": "adminsecretpwd",
        "employee_id": admin_data["_id"]
    }

@pytest.fixture(scope="function")
async def test_employee_user() -> Dict[str, str]:
    """
    Seeds a standard test employee user profile in the database and returns credentials.
    """
    db = get_loop_safe_database()
    emp_data = {
        "employee_code": "NV002",
        "username": "testemployee",
        "hashed_password": get_password_hash("employeesecretpwd"),
        "full_name": "Test Employee Staff",
        "email": "testemployee@ecommerce.com",
        "role": Role.EMPLOYEE.value,
        "status": EmployeeStatus.ACTIVE.value,
        "platforms": [Platform.SHOPEE.value]
    }
    
    await db["employees"].delete_one({"username": "testemployee"})
    res = await db["employees"].insert_one(emp_data)
    emp_data["_id"] = str(res.inserted_id)
    
    return {
        "username": "testemployee",
        "password": "employeesecretpwd",
        "employee_id": emp_data["_id"]
    }

@pytest.fixture(scope="function")
async def admin_headers(client: AsyncClient, test_admin_user: Dict[str, str]) -> Dict[str, str]:
    res = await client.post("/api/v1/auth/login", json={
        "username": test_admin_user["username"],
        "password": test_admin_user["password"]
    })
    assert res.status_code == 200
    token = res.json()["access_token"]
    return {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }

@pytest.fixture(scope="function")
async def employee_headers(client: AsyncClient, test_employee_user: Dict[str, str]) -> Dict[str, str]:
    res = await client.post("/api/v1/auth/login", json={
        "username": test_employee_user["username"],
        "password": test_employee_user["password"]
    })
    assert res.status_code == 200
    token = res.json()["access_token"]
    return {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }
