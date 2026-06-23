import logging
from app.db.client import MongoClientManager

logger = logging.getLogger("app.db.indexes")


async def ensure_indexes() -> None:
    """
    Idempotently creates indexes for production collections to ensure performance.
    """
    db = MongoClientManager.db
    if db is None:
        logger.error("Database connection is not initialized. Skipping index creation.")
        return

    logger.info("Ensuring database indexes exist...")

    # 1. Orders Collection Indexes
    try:
        await db["orders"].create_index([("status", 1), ("created_at", 1)], name="idx_orders_status_created_at")
        await db["orders"].create_index([("created_at", -1)], name="idx_orders_created_at_desc")
    except Exception as e:
        logger.error(f"Error creating indexes on orders: {e}")

    # 2. Employee Sessions Collection Indexes
    try:
        await db["employee_sessions"].create_index([("expires_at", 1)], name="idx_sessions_expires_at")
        await db["employee_sessions"].create_index([("last_activity_at", 1)], name="idx_sessions_last_activity_at")
        await db["employee_sessions"].create_index([("created_at", -1)], name="idx_sessions_created_at_desc")
    except Exception as e:
        logger.error(f"Error creating indexes on employee_sessions: {e}")

    # 3. Audit Logs Collection Indexes
    try:
        await db["audit_logs"].create_index([("created_at", -1)], name="idx_audit_logs_created_at_desc")
    except Exception as e:
        logger.error(f"Error creating indexes on audit_logs: {e}")

    # 4. Notifications Collection Indexes
    try:
        await db["notifications"].create_index([("created_at", -1)], name="idx_notifications_created_at_desc")
    except Exception as e:
        logger.error(f"Error creating indexes on notifications: {e}")

    # 5. Revenues Collection Indexes
    try:
        await db["revenues"].create_index([("employee_id", 1), ("date", 1)], name="idx_revenues_employee_date")
        await db["revenues"].create_index([("date", 1)], name="idx_revenues_date")
    except Exception as e:
        logger.error(f"Error creating indexes on revenues: {e}")

    # 6. Additional Modules (KPI, Rewards, Product Activities, Reports, Blacklist)
    try:
        await db["kpi_daily"].create_index([("date", 1)], name="idx_kpi_daily_date")
        await db["rewards"].create_index([("employee_id", 1), ("created_at", -1)], name="idx_rewards_employee_created")
        await db["product_activities"].create_index([("created_at", -1)], name="idx_product_activities_created_desc")
        await db["reports"].create_index([("created_at", -1)], name="idx_reports_created_desc")
        await db["customer_blacklist"].create_index([("customer_phone", 1)], unique=True, name="idx_blacklist_phone")
    except Exception as e:
        logger.error(f"Error creating auxiliary module indexes: {e}")

    logger.info("Database index creation checks completed.")
