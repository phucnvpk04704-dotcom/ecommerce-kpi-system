from datetime import datetime, timezone, timedelta
from decimal import Decimal
import asyncio
from bson.decimal128 import Decimal128
from motor.motor_asyncio import AsyncIOMotorDatabase

from app.models.order import Order
from app.models.audit_log import AuditLog
from app.models.employee_session import EmployeeSession
from app.models.notification import Notification


def to_decimal(val) -> Decimal:
    if isinstance(val, Decimal128):
        return val.to_decimal()
    if val is not None:
        return Decimal(str(val))
    return Decimal("0.00")


class DashboardService:
    """
    Service layer responsible for performing aggregations across multiple MongoDB collections
    to feed the administrative dashboard.
    """
    def __init__(self, db: AsyncIOMotorDatabase):
        self.db = db

    async def get_summary(self) -> dict:
        """
        Retrieves global administrative statistics:
        - total_orders (estimated)
        - total_revenue (from completed orders)
        - total_employees (estimated)
        - active_sessions (expires_at in the future)
        - total_notifications (estimated)
        - blacklisted_customers (estimated)
        All queries executed concurrently.
        """
        now = datetime.now(timezone.utc)

        # Sum total revenue for completed orders
        pipeline = [
            {"$match": {"status": "Completed"}},
            {"$group": {"_id": None, "total": {"$sum": "$total_amount"}}}
        ]

        # Use estimated_document_count() for O(1) collection metadata checks.
        # Run all database calls concurrently via asyncio.gather.
        (
            total_orders,
            total_employees,
            active_sessions,
            total_notifications,
            blacklisted_customers,
            revenue_res
        ) = await asyncio.gather(
            self.db["orders"].estimated_document_count(),
            self.db["employees"].estimated_document_count(),
            self.db["employee_sessions"].count_documents({"expires_at": {"$gt": now}}),
            self.db["notifications"].estimated_document_count(),
            self.db["customer_blacklist"].estimated_document_count(),
            self.db["orders"].aggregate(pipeline).to_list(length=1)
        )

        total_revenue = to_decimal(revenue_res[0].get("total")) if revenue_res else Decimal("0.00")

        return {
            "total_orders": total_orders,
            "total_revenue": total_revenue,
            "total_employees": total_employees,
            "active_sessions": active_sessions,
            "total_notifications": total_notifications,
            "blacklisted_customers": blacklisted_customers
        }

    async def get_kpi(self) -> dict:
        """
        Retrieves daily performance indicators and growth metrics:
        - orders_today
        - revenue_today
        - active_users_today
        - growth_rate
        Optimized by combining orders today/yesterday queries into a single aggregation.
        """
        now = datetime.now(timezone.utc)
        start_of_today = now.replace(hour=0, minute=0, second=0, microsecond=0)
        start_of_yesterday = start_of_today - timedelta(days=1)

        # Single aggregation on orders to retrieve orders_today, revenue_today, and revenue_yesterday
        orders_pipeline = [
            {
                "$match": {
                    "created_at": {"$gte": start_of_yesterday, "$lte": now}
                }
            },
            {
                "$group": {
                    "_id": None,
                    "orders_today": {
                        "$sum": {
                            "$cond": [
                                {"$gte": ["$created_at", start_of_today]},
                                1,
                                0
                            ]
                        }
                    },
                    "revenue_today": {
                        "$sum": {
                            "$cond": [
                                {
                                    "$and": [
                                        {"$eq": ["$status", "Completed"]},
                                        {"$gte": ["$created_at", start_of_today]}
                                    ]
                                },
                                "$total_amount",
                                0
                            ]
                        }
                    },
                    "revenue_yesterday": {
                        "$sum": {
                            "$cond": [
                                {
                                    "$and": [
                                        {"$eq": ["$status", "Completed"]},
                                        {"$lt": ["$created_at", start_of_today]}
                                    ]
                                },
                                "$total_amount",
                                0
                            ]
                        }
                    }
                }
            }
        ]

        # Aggregation on employee sessions for unique active users
        sessions_pipeline = [
            {
                "$match": {
                    "last_activity_at": {"$gte": start_of_today}
                }
            },
            {"$group": {"_id": "$employee_id"}}
        ]

        # Execute orders aggregation and active sessions aggregation concurrently
        orders_res, sessions_res = await asyncio.gather(
            self.db["orders"].aggregate(orders_pipeline).to_list(length=1),
            self.db["employee_sessions"].aggregate(sessions_pipeline).to_list(length=1000)
        )

        if orders_res:
            orders_today = orders_res[0].get("orders_today", 0)
            revenue_today = to_decimal(orders_res[0].get("revenue_today"))
            revenue_yesterday = to_decimal(orders_res[0].get("revenue_yesterday"))
        else:
            orders_today = 0
            revenue_today = Decimal("0.00")
            revenue_yesterday = Decimal("0.00")

        active_users_today = len(sessions_res)

        # Growth rate calculation (today vs yesterday)
        growth_rate = 0.0
        if revenue_yesterday > 0:
            growth_rate = float((revenue_today - revenue_yesterday) / revenue_yesterday)
        elif revenue_today > 0:
            growth_rate = 1.0

        return {
            "orders_today": orders_today,
            "revenue_today": revenue_today,
            "active_users_today": active_users_today,
            "growth_rate": growth_rate
        }

    async def get_revenue_chart(self) -> list:
        """
        Aggregates daily revenue for the last 30 days.
        """
        now = datetime.now(timezone.utc)
        start_date = now - timedelta(days=30)
        start_of_period = start_date.replace(hour=0, minute=0, second=0, microsecond=0)

        pipeline = [
            {
                "$match": {
                    "status": "Completed",
                    "created_at": {"$gte": start_of_period}
                }
            },
            {
                "$group": {
                    "_id": {
                        "$dateToString": {"format": "%Y-%m-%d", "date": "$created_at"}
                    },
                    "revenue": {"$sum": "$total_amount"}
                }
            },
            {"$sort": {"_id": 1}}
        ]

        results = await self.db["orders"].aggregate(pipeline).to_list(length=50)
        chart_data = []

        # Map results for quick lookup and fill missing dates with 0.00
        date_map = {res["_id"]: to_decimal(res["revenue"]) for res in results}
        for d in range(30):
            curr_date = (start_of_period + timedelta(days=d)).strftime("%Y-%m-%d")
            chart_data.append({
                "date": curr_date,
                "revenue": date_map.get(curr_date, Decimal("0.00"))
            })

        return chart_data

    async def get_orders_chart(self) -> list:
        """
        Aggregates daily order count for the last 30 days.
        """
        now = datetime.now(timezone.utc)
        start_date = now - timedelta(days=30)
        start_of_period = start_date.replace(hour=0, minute=0, second=0, microsecond=0)

        pipeline = [
            {
                "$match": {
                    "created_at": {"$gte": start_of_period}
                }
            },
            {
                "$group": {
                    "_id": {
                        "$dateToString": {"format": "%Y-%m-%d", "date": "$created_at"}
                    },
                    "count": {"$sum": 1}
                }
            },
            {"$sort": {"_id": 1}}
        ]

        results = await self.db["orders"].aggregate(pipeline).to_list(length=50)
        chart_data = []

        date_map = {res["_id"]: res["count"] for res in results}
        for d in range(30):
            curr_date = (start_of_period + timedelta(days=d)).strftime("%Y-%m-%d")
            chart_data.append({
                "date": curr_date,
                "order_count": date_map.get(curr_date, 0)
            })

        return chart_data

    async def get_recent_activities(self) -> dict:
        """
        Retrieves the 5 most recent records from multiple modules concurrently.
        """
        # Execute queries concurrently via asyncio.gather
        orders_task = self.db["orders"].find({}).sort("created_at", -1).limit(5).to_list(length=5)
        audits_task = self.db["audit_logs"].find({}).sort("created_at", -1).limit(5).to_list(length=5)
        sessions_task = self.db["employee_sessions"].find({}).sort("created_at", -1).limit(5).to_list(length=5)
        notifs_task = self.db["notifications"].find({}).sort("created_at", -1).limit(5).to_list(length=5)

        orders_docs, audits_docs, sessions_docs, notifs_docs = await asyncio.gather(
            orders_task, audits_task, sessions_task, notifs_task
        )

        recent_orders = [Order.model_validate(doc) for doc in orders_docs]
        recent_audit_logs = [AuditLog.model_validate(doc) for doc in audits_docs]
        recent_sessions = [EmployeeSession.model_validate(doc) for doc in sessions_docs]
        recent_notifications = [Notification.model_validate(doc) for doc in notifs_docs]

        return {
            "recent_orders": recent_orders,
            "recent_audit_logs": recent_audit_logs,
            "recent_sessions": recent_sessions,
            "recent_notifications": recent_notifications
        }
