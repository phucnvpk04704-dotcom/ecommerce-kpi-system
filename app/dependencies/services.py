from typing import Annotated
from fastapi import Depends
from motor.motor_asyncio import AsyncIOMotorDatabase

# Import database dependency provider (falls back to client if dependencies/db.py is empty)
try:
    from app.dependencies.db import get_database
except ImportError:
    from app.db.client import get_database

# Repositories
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

# Services
from app.services.auth import AuthService
from app.services.employee import EmployeeService
from app.services.employee_session import EmployeeSessionService
from app.services.order import OrderService
from app.services.chat import ChatService
from app.services.product_activity import ProductActivityService
from app.services.revenue import RevenueService
from app.services.kpi import KPIService
from app.services.reward import RewardService
from app.services.customer_blacklist import CustomerBlacklistService
from app.services.notification import NotificationService
from app.services.report import ReportService
from app.services.setting import SettingService
from app.services.audit_log import AuditLogService
from app.services.dashboard import DashboardService



# ==========================================
# Repository Dependency Providers
# ==========================================

def get_employee_repository(
    db: Annotated[AsyncIOMotorDatabase, Depends(get_database)]
) -> EmployeeRepository:
    return EmployeeRepository(db["employees"])


def get_employee_session_repository(
    db: Annotated[AsyncIOMotorDatabase, Depends(get_database)]
) -> EmployeeSessionRepository:
    return EmployeeSessionRepository(db["employee_sessions"])


def get_order_repository(
    db: Annotated[AsyncIOMotorDatabase, Depends(get_database)]
) -> OrderRepository:
    return OrderRepository(db["orders"])


def get_chat_repository(
    db: Annotated[AsyncIOMotorDatabase, Depends(get_database)]
) -> ChatRepository:
    return ChatRepository(db["chats"])


def get_product_activity_repository(
    db: Annotated[AsyncIOMotorDatabase, Depends(get_database)]
) -> ProductActivityRepository:
    return ProductActivityRepository(db["product_activities"])


def get_revenue_repository(
    db: Annotated[AsyncIOMotorDatabase, Depends(get_database)]
) -> RevenueRepository:
    return RevenueRepository(db["revenues"])


def get_kpi_repository(
    db: Annotated[AsyncIOMotorDatabase, Depends(get_database)]
) -> KPIDailyRepository:
    return KPIDailyRepository(db["kpi_daily"])


def get_reward_repository(
    db: Annotated[AsyncIOMotorDatabase, Depends(get_database)]
) -> RewardRepository:
    return RewardRepository(db["rewards"])


def get_customer_blacklist_repository(
    db: Annotated[AsyncIOMotorDatabase, Depends(get_database)]
) -> CustomerBlacklistRepository:
    return CustomerBlacklistRepository(db["customer_blacklist"])


def get_notification_repository(
    db: Annotated[AsyncIOMotorDatabase, Depends(get_database)]
) -> NotificationRepository:
    return NotificationRepository(db["notifications"])


def get_report_repository(
    db: Annotated[AsyncIOMotorDatabase, Depends(get_database)]
) -> ReportRepository:
    return ReportRepository(db["reports"])


def get_setting_repository(
    db: Annotated[AsyncIOMotorDatabase, Depends(get_database)]
) -> SettingRepository:
    return SettingRepository(db["settings"])


def get_audit_log_repository(
    db: Annotated[AsyncIOMotorDatabase, Depends(get_database)]
) -> AuditLogRepository:
    return AuditLogRepository(db["audit_logs"])


# ==========================================
# Service Dependency Providers
# ==========================================

def get_auth_service(
    employee_repository: Annotated[EmployeeRepository, Depends(get_employee_repository)],
    session_repository: Annotated[EmployeeSessionRepository, Depends(get_employee_session_repository)]
) -> AuthService:
    return AuthService(employee_repository, session_repository)


def get_employee_service(
    employee_repository: Annotated[EmployeeRepository, Depends(get_employee_repository)]
) -> EmployeeService:
    return EmployeeService(employee_repository)


def get_employee_session_service(
    employee_session_repository: Annotated[EmployeeSessionRepository, Depends(get_employee_session_repository)]
) -> EmployeeSessionService:
    return EmployeeSessionService(employee_session_repository)


def get_order_service(
    order_repository: Annotated[OrderRepository, Depends(get_order_repository)]
) -> OrderService:
    return OrderService(order_repository)


def get_chat_service(
    chat_repository: Annotated[ChatRepository, Depends(get_chat_repository)]
) -> ChatService:
    return ChatService(chat_repository)


def get_product_activity_service(
    product_activity_repository: Annotated[ProductActivityRepository, Depends(get_product_activity_repository)]
) -> ProductActivityService:
    return ProductActivityService(product_activity_repository)


def get_revenue_service(
    revenue_repository: Annotated[RevenueRepository, Depends(get_revenue_repository)]
) -> RevenueService:
    return RevenueService(revenue_repository)


def get_kpi_service(
    kpi_daily_repository: Annotated[KPIDailyRepository, Depends(get_kpi_repository)]
) -> KPIService:
    return KPIService(kpi_daily_repository)


def get_reward_service(
    reward_repository: Annotated[RewardRepository, Depends(get_reward_repository)]
) -> RewardService:
    return RewardService(reward_repository)


def get_customer_blacklist_service(
    customer_blacklist_repository: Annotated[CustomerBlacklistRepository, Depends(get_customer_blacklist_repository)],
    order_repository: Annotated[OrderRepository, Depends(get_order_repository)]
) -> CustomerBlacklistService:
    return CustomerBlacklistService(customer_blacklist_repository, order_repository)


def get_notification_service(
    notification_repository: Annotated[NotificationRepository, Depends(get_notification_repository)]
) -> NotificationService:
    return NotificationService(notification_repository)


def get_report_service(
    report_repository: Annotated[ReportRepository, Depends(get_report_repository)]
) -> ReportService:
    return ReportService(report_repository)


def get_setting_service(
    setting_repository: Annotated[SettingRepository, Depends(get_setting_repository)]
) -> SettingService:
    return SettingService(setting_repository)


def get_audit_log_service(
    audit_log_repository: Annotated[AuditLogRepository, Depends(get_audit_log_repository)]
) -> AuditLogService:
    return AuditLogService(audit_log_repository)


def get_dashboard_service(
    db: Annotated[AsyncIOMotorDatabase, Depends(get_database)]
) -> DashboardService:
    return DashboardService(db)

