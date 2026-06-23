import random
from datetime import datetime, timedelta, timezone
import pymongo
from bson import ObjectId
from app.core.config import settings
from app.core.security import get_password_hash
from app.core.enums.employee import Role, EmployeeStatus
from app.core.enums.platform import Platform
from app.core.enums.order import OrderStatus
from app.core.enums.period import Period
from app.core.enums.kpi import KPIClassification
from app.core.enums.notification import NotificationType
from app.core.enums.reward import RewardStatus
from app.core.enums.audit import AuditAction
from app.core.enums.report import ReportType, ReportSentStatus
from app.core.enums.product_activity import ProductActivityType
from app.core.enums.risk_level import RiskLevel


def seed_database():
    print(f"Connecting to MongoDB at {settings.MONGODB_URL}...")
    client = pymongo.MongoClient(settings.MONGODB_URL)
    db = client[settings.DATABASE_NAME]

    # Clear existing collections to ensure clean seed
    collections_to_clear = [
        "orders", "revenues", "kpi_daily", "notifications",
        "rewards", "audit_logs", "reports", "product_activities",
        "customer_blacklist"
    ]
    for col in collections_to_clear:
        db[col].delete_many({})
        print(f"Cleared collection: {col}")

    # 1. Verify or create employees
    employees_col = db["employees"]
    admin = employees_col.find_one({"role": Role.ADMIN.value})
    if not admin:
        admin_data = {
            "employee_code": "NV001",
            "username": "admin",
            "hashed_password": get_password_hash("admin123456"),
            "full_name": "System Administrator",
            "email": "admin@ecommercekpi.com",
            "role": Role.ADMIN.value,
            "status": EmployeeStatus.ACTIVE.value,
            "platforms": [Platform.ALL.value],
            "created_at": datetime.now(timezone.utc),
            "updated_at": datetime.now(timezone.utc)
        }
        admin_id = employees_col.insert_one(admin_data).inserted_id
        admin = employees_col.find_one({"_id": admin_id})
        print(f"Created Admin: {admin['username']}")
    else:
        admin_id = admin["_id"]
        print(f"Found Admin: {admin['username']}")

    employee = employees_col.find_one({"role": Role.EMPLOYEE.value})
    if not employee:
        emp_data = {
            "employee_code": "NV002",
            "username": "testuser",
            "hashed_password": get_password_hash("testpassword"),
            "full_name": "Test Employee",
            "email": "testuser@ecommercekpi.com",
            "role": Role.EMPLOYEE.value,
            "status": EmployeeStatus.ACTIVE.value,
            "platforms": [Platform.SHOPEE.value, Platform.LAZADA.value],
            "created_at": datetime.now(timezone.utc),
            "updated_at": datetime.now(timezone.utc)
        }
        emp_id = employees_col.insert_one(emp_data).inserted_id
        employee = employees_col.find_one({"_id": emp_id})
        print(f"Created Employee: {employee['username']}")
    else:
        emp_id = employee["_id"]
        print(f"Found Employee: {employee['username']}")

    user_ids = [admin_id, emp_id]
    platforms = [Platform.SHOPEE.value, Platform.LAZADA.value, Platform.TIKTOK.value, Platform.TIKI.value]

    # Time frame: last 365 days
    now = datetime.now(timezone.utc)
    start_date = now - timedelta(days=365)

    # 2. Seed 500 Orders
    print("Seeding 500 Orders...")
    orders_data = []
    statuses = [OrderStatus.COMPLETED.value] * 8 + [OrderStatus.CANCELLED.value, OrderStatus.RETURNED.value, OrderStatus.LATE.value, OrderStatus.PENDING.value]
    cancel_reasons = ["Out of stock", "Customer cancelled", "Incorrect shipping address", "Payment failed"]
    return_reasons = ["Damaged item", "Wrong size", "Defective product", "Changed mind"]
    
    for i in range(1, 501):
        order_date = start_date + timedelta(seconds=random.randint(0, 365 * 24 * 3600))
        status = random.choice(statuses)
        total_amount = round(random.uniform(50000.0, 2500000.0), 2)
        
        cancel_reason = random.choice(cancel_reasons) if status == OrderStatus.CANCELLED.value else None
        return_reason = random.choice(return_reasons) if status == OrderStatus.RETURNED.value else None
        
        orders_data.append({
            "order_id": f"ORD-{order_date.strftime('%Y%m%d')}-{i:04d}",
            "platform": random.choice(platforms),
            "customer_id": f"CUST-{random.randint(1000, 9999)}",
            "customer_name": f"Customer {i}",
            "customer_phone": f"09{random.randint(10000000, 99999999)}",
            "confirmed_by": random.choice(user_ids),
            "total_amount": total_amount,
            "status": status,
            "cancel_reason": cancel_reason,
            "return_reason": return_reason,
            "confirmed_at": order_date + timedelta(minutes=random.randint(5, 60)) if status != OrderStatus.PENDING.value else None,
            "completed_at": order_date + timedelta(days=random.randint(1, 3)) if status == OrderStatus.COMPLETED.value else None,
            "cancelled_at": order_date + timedelta(hours=random.randint(1, 12)) if status == OrderStatus.CANCELLED.value else None,
            "returned_at": order_date + timedelta(days=random.randint(3, 7)) if status == OrderStatus.RETURNED.value else None,
            "late_at": order_date + timedelta(days=random.randint(4, 5)) if status == OrderStatus.LATE.value else None,
            "created_at": order_date,
            "updated_at": order_date
        })
    db["orders"].insert_many(orders_data)
    print("Orders seeded successfully.")

    # 3. Seed 365 Daily Revenues
    print("Seeding 365 Revenues...")
    revenues_data = []
    for d in range(366):
        record_date = start_date + timedelta(days=d)
        for uid in user_ids:
            for platform in platforms[:2]: # seed for 2 platforms per user
                tot_orders = random.randint(5, 30)
                cancelled = random.randint(0, 3)
                returned = random.randint(0, 2)
                successful = tot_orders - (cancelled + returned)
                
                tot_revenue = successful * random.uniform(100000.0, 500000.0)
                tgt_revenue = random.uniform(800000.0, 1500000.0)
                
                revenues_data.append({
                    "employee_id": uid,
                    "platform": platform,
                    "date": record_date,
                    "period": Period.DAILY.value,
                    "total_orders": tot_orders,
                    "successful_orders": successful,
                    "returned_orders": returned,
                    "cancelled_orders": cancelled,
                    "total_revenue": round(tot_revenue, 2),
                    "target_revenue": round(tgt_revenue, 2),
                    "created_at": record_date,
                    "updated_at": record_date
                })
    db["revenues"].insert_many(revenues_data)
    print("Revenues seeded successfully.")

    # 4. Seed 365 KPI Daily Records
    print("Seeding 365 KPIs...")
    kpi_data = []
    classifications = [KPIClassification.EXCELLENT.value, KPIClassification.GOOD.value, KPIClassification.FAIR.value, KPIClassification.PASS.value, KPIClassification.FAILED.value]
    for d in range(366):
        record_date = start_date + timedelta(days=d)
        for uid in user_ids:
            o_score = random.uniform(30.0, 40.0)
            c_score = random.uniform(15.0, 20.0)
            p_score = random.uniform(10.0, 15.0)
            r_score = random.uniform(15.0, 25.0)
            penalty = random.choice([0.0] * 9 + [5.0, 10.0])
            total_kpi = min(100.0, o_score + c_score + p_score + r_score - penalty)
            
            if total_kpi >= 90.0:
                cls = KPIClassification.EXCELLENT.value
            elif total_kpi >= 80.0:
                cls = KPIClassification.GOOD.value
            elif total_kpi >= 65.0:
                cls = KPIClassification.FAIR.value
            elif total_kpi >= 50.0:
                cls = KPIClassification.PASS.value
            else:
                cls = KPIClassification.FAILED.value
                
            kpi_data.append({
                "employee_id": uid,
                "date": record_date,
                "orders_score": round(o_score, 2),
                "chats_score": round(c_score, 2),
                "products_score": round(p_score, 2),
                "revenue_score": round(r_score, 2),
                "penalty_deductions": round(penalty, 2),
                "total_kpi_score": round(total_kpi, 2),
                "classification": cls,
                "details": {"note": "Automated system calculations"},
                "created_at": record_date
            })
    db["kpi_daily"].insert_many(kpi_data)
    print("KPI Daily seeded successfully.")

    # 5. Seed 50 Notifications
    print("Seeding 50 Notifications...")
    notifications_data = []
    notif_types = [NotificationType.KPI_ALERT.value, NotificationType.BLACKLIST_ALERT.value, NotificationType.SYSTEM.value]
    titles = {
        NotificationType.KPI_ALERT.value: ["Daily KPI Target Achieved!", "KPI Score Fall Warning", "Weekly Review Pending"],
        NotificationType.BLACKLIST_ALERT.value: ["New Blacklist Customer Alert", "Fraudulent Order Blocked", "Blacklist Sync Complete"],
        NotificationType.SYSTEM.value: ["System Maintenance Notice", "Database Update Completed", "Monthly Review Schedule"]
    }
    
    for i in range(1, 51):
        notif_date = start_date + timedelta(seconds=random.randint(0, 365 * 24 * 3600))
        ntype = random.choice(notif_types)
        title = random.choice(titles[ntype])
        body = f"Detailed notification payload for {title.lower()} generated at {notif_date.strftime('%Y-%m-%d %H:%M:%S')}"
        
        notifications_data.append({
            "recipient_role": random.choice([Role.ADMIN.value, Role.MANAGER.value, Role.EMPLOYEE.value, None]),
            "recipient_id": random.choice(user_ids) if random.choice([True, False]) else None,
            "title": title,
            "body": body,
            "type": ntype,
            "is_read": random.choice([True, False]),
            "created_at": notif_date
        })
    db["notifications"].insert_many(notifications_data)
    print("Notifications seeded successfully.")

    # 6. Seed 100 Rewards
    print("Seeding 100 Rewards...")
    rewards_data = []
    reward_statuses = [RewardStatus.PENDING.value, RewardStatus.APPROVED.value, RewardStatus.PAID.value]
    for i in range(1, 101):
        reward_date = start_date + timedelta(seconds=random.randint(0, 365 * 24 * 3600))
        rewards_data.append({
            "employee_id": random.choice(user_ids),
            "date": reward_date,
            "period": random.choice([Period.DAILY.value, Period.MONTHLY.value]),
            "kpi_score": round(random.uniform(70.0, 100.0), 2),
            "reward_amount": round(random.uniform(200000.0, 5000000.0), 2),
            "currency": "VND",
            "status": random.choice(reward_statuses),
            "created_at": reward_date,
            "updated_at": reward_date
        })
    db["rewards"].insert_many(rewards_data)
    print("Rewards seeded successfully.")

    # 7. Seed 1000 Audit Logs
    print("Seeding 1000 Audit Logs...")
    audit_data = []
    actions = [AuditAction.UPDATE_KPI_RULE.value, AuditAction.UPDATE_REWARD_RULE.value, AuditAction.CREATE_EMPLOYEE.value, AuditAction.DELETE_EMPLOYEE.value, AuditAction.BLACKLIST_CUSTOMER.value]
    entities = {
        AuditAction.UPDATE_KPI_RULE.value: ("kpi_rules", "RULE001"),
        AuditAction.UPDATE_REWARD_RULE.value: ("reward_rules", "RULE002"),
        AuditAction.CREATE_EMPLOYEE.value: ("employees", "NV003"),
        AuditAction.DELETE_EMPLOYEE.value: ("employees", "NV004"),
        AuditAction.BLACKLIST_CUSTOMER.value: ("customer_blacklist", "CUST999")
    }
    
    for i in range(1, 1001):
        log_date = start_date + timedelta(seconds=random.randint(0, 365 * 24 * 3600))
        action = random.choice(actions)
        entity_type, entity_id = entities[action]
        
        audit_data.append({
            "user_id": random.choice(user_ids),
            "action": action,
            "entity_type": entity_type,
            "entity_id": entity_id,
            "old_value": {"status": "inactive"},
            "new_value": {"status": "active"},
            "created_at": log_date
        })
    db["audit_logs"].insert_many(audit_data)
    print("Audit Logs seeded successfully.")

    # 8. Seed 50 Reports
    print("Seeding 50 Reports...")
    reports_data = []
    report_types = [ReportType.DAILY_EMAIL.value, ReportType.MONTHLY_SUMMARY.value]
    report_sent_statuses = [ReportSentStatus.SENT.value] * 9 + [ReportSentStatus.FAILED.value]
    
    for i in range(1, 51):
        report_date = start_date + timedelta(seconds=random.randint(0, 365 * 24 * 3600))
        r_type = random.choice(report_types)
        successful_orders = random.randint(100, 1500)
        total_revenue = successful_orders * random.uniform(100000.0, 300000.0)
        
        reports_data.append({
            "report_type": r_type,
            "date": report_date,
            "recipients": ["admin@ecommercekpi.com", "manager@ecommercekpi.com"],
            "total_revenue": round(total_revenue, 2),
            "total_orders": successful_orders,
            "top_employee": random.choice(["System Administrator", "Test Employee"]),
            "new_blacklist_count": random.randint(0, 5),
            "summary_data": {"note": "Generated automatically by system report cron jobs"},
            "sent_status": random.choice(report_sent_statuses),
            "created_at": report_date
        })
    db["reports"].insert_many(reports_data)
    print("Reports seeded successfully.")

    # 9. Seed 1000 Product Activities
    print("Seeding 1000 Product Activities...")
    activities_data = []
    act_types = [ProductActivityType.CREATE.value, ProductActivityType.UPDATE.value]
    
    for i in range(1, 1001):
        act_date = start_date + timedelta(seconds=random.randint(0, 365 * 24 * 3600))
        activities_data.append({
            "employee_id": random.choice(user_ids),
            "platform": random.choice(platforms),
            "product_id": f"PROD-{random.randint(100000, 999999)}",
            "activity_type": random.choice(act_types),
            "timestamp": act_date,
            "created_at": act_date
        })
    db["product_activities"].insert_many(activities_data)
    print("Product Activities seeded successfully.")

    # 10. Seed 20 Customer Blacklist Entries (Bonus)
    print("Seeding 20 Customer Blacklist entries...")
    blacklist_data = []
    blacklist_levels = [RiskLevel.LOW.value, RiskLevel.MEDIUM.value, RiskLevel.HIGH.value, RiskLevel.BLACKLIST.value]
    for i in range(1, 21):
        blacklist_date = start_date + timedelta(seconds=random.randint(0, 365 * 24 * 3600))
        blacklist_data.append({
            "customer_id": f"CUST-BL-{i:03d}",
            "platform": random.choice(platforms),
            "customer_name": f"Blacklisted Customer {i}",
            "customer_phone": f"098{random.randint(1000000, 9999999)}",
            "total_orders": random.randint(10, 50),
            "cancelled_orders": random.randint(5, 20),
            "returned_orders": random.randint(3, 10),
            "risk_score": round(random.uniform(30.0, 99.0), 2),
            "risk_level": random.choice(blacklist_levels),
            "last_order_at": blacklist_date,
            "added_at": blacklist_date,
            "created_at": blacklist_date,
            "updated_at": blacklist_date
        })
    db["customer_blacklist"].insert_many(blacklist_data)
    print("Customer Blacklist seeded successfully.")

    print("\nDatabase seeding completed successfully!")
    client.close()


if __name__ == "__main__":
    seed_database()
