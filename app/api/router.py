from fastapi import APIRouter

from app.api.v1.auth import router as auth_router
from app.api.v1.employees import router as employees_router
from app.api.v1.orders import router as orders_router
from app.api.v1.chats import router as chats_router
from app.api.v1.notifications import router as notifications_router
from app.api.v1.revenues import router as revenues_router
from app.api.v1.kpi import router as kpi_router
from app.api.v1.rewards import router as rewards_router
from app.api.v1.reports import router as reports_router
from app.api.v1.customer_blacklist import router as customer_blacklist_router
from app.api.v1.settings import router as settings_router
from app.api.v1.audit_logs import router as audit_logs_router
from app.api.v1.employee_sessions import router as employee_sessions_router
from app.api.v1.product_activities import router as product_activities_router
from app.api.v1.dashboard import router as dashboard_router

api_router = APIRouter()

api_router.include_router(auth_router)
api_router.include_router(employees_router)
api_router.include_router(orders_router)
api_router.include_router(chats_router)
api_router.include_router(notifications_router)
api_router.include_router(revenues_router)
api_router.include_router(kpi_router)
api_router.include_router(rewards_router)
api_router.include_router(reports_router)
api_router.include_router(customer_blacklist_router)
api_router.include_router(settings_router)
api_router.include_router(audit_logs_router)
api_router.include_router(employee_sessions_router)
api_router.include_router(product_activities_router)
api_router.include_router(dashboard_router)

