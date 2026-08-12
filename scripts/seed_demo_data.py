import sys
import os
import random
from datetime import datetime, timedelta, timezone
from decimal import Decimal
import pymongo
from bson import ObjectId
from bson.codec_options import TypeCodec, TypeRegistry, CodecOptions
from bson.decimal128 import Decimal128

# Add project root to sys.path to allow imports from app
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

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

# Custom PyMongo TypeCodec to convert python Decimal to BSON Decimal128 and vice-versa
class DecimalCodec(TypeCodec):
    python_type = Decimal
    bson_type = Decimal128

    def transform_python(self, value):
        return Decimal128(value)

    def transform_bson(self, value):
        return value.to_decimal()

# Define Vietnamese name pools for realistic data generation
HO_LIST = ["Nguyễn", "Trần", "Lê", "Phạm", "Hoàng", "Huỳnh", "Phan", "Vũ", "Võ", "Đặng", "Bùi", "Đỗ", "Hồ", "Ngô", "Dương", "Lý", "Vương"]
DEM_LIST = ["Văn", "Thị", "Minh", "Anh", "Đức", "Duy", "Hữu", "Quốc", "Ngọc", "Bảo", "Thanh", "Xuân", "Mạnh", "Tuấn", "Thành", "Hoài", "Thu", "Nguyên"]
TEN_LIST = ["Anh", "Bình", "Cường", "Dũng", "Đạt", "Giang", "Hải", "Hùng", "Huy", "Khánh", "Linh", "Minh", "Nam", "Phong", "Phúc", "Quân", "Sơn", "Thảo", "Trang", "Tuấn", "Việt", "Vy", "Hương", "Lan", "Hà", "Tiến", "Tùng", "Lâm", "Hải", "Dương", "Trực"]

def generate_vietnamese_names(count):
    names = set()
    while len(names) < count:
        ho = random.choice(HO_LIST)
        dem = random.choice(DEM_LIST)
        ten = random.choice(TEN_LIST)
        name = f"{ho} {dem} {ten}"
        names.add(name)
    return list(names)

def generate_vietnamese_phones(count):
    # Unique Vietnamese phone number generator
    prefixes = ["090", "091", "098", "097", "096", "083", "085", "070", "077", "035", "038", "056"]
    phones = []
    for i in range(count):
        prefix = prefixes[i % len(prefixes)]
        # Generate unique suffix sequence
        suffix = f"{(i // len(prefixes)) * 17 + 1234567:07d}"
        phones.append(f"{prefix}{suffix}")
    return phones

def seed_database():
    print(f"Connecting to MongoDB at {settings.MONGODB_URL}...")
    codec_options = CodecOptions(type_registry=TypeRegistry([DecimalCodec()]))
    client = pymongo.MongoClient(settings.MONGODB_URL)
    db = client.get_database(settings.DATABASE_NAME, codec_options=codec_options)

    # 1. Clear existing collections to ensure clean and exact seeding
    collections_to_clear = [
        "employees", "orders", "revenues", "kpi_daily", "notifications",
        "rewards", "audit_logs", "reports", "product_activities",
        "customer_blacklist", "employee_sessions"
    ]
    print("Clearing existing collections...")
    for col in collections_to_clear:
        db[col].delete_many({})
        print(f"Cleared collection: {col}")

    # Set random seed for consistency
    random.seed(42)

    # 2. Seed 20 Employees
    print("\nGenerating 20 employees...")
    employees_data = []
    
    # Preset key accounts to preserve credentials required by development/tests
    # Admin (NV001)
    employees_data.append({
        "employee_code": "NV001",
        "username": "admin",
        "hashed_password": get_password_hash("admin123456"),
        "full_name": "Nguyễn Văn Trị",
        "email": "admin@ecommercekpi.com",
        "role": Role.ADMIN.value,
        "status": EmployeeStatus.ACTIVE.value,
        "platforms": [Platform.ALL.value],
        "created_at": datetime.now(timezone.utc) - timedelta(days=365),
        "updated_at": datetime.now(timezone.utc) - timedelta(days=365)
    })
    # Manager 1 (NV002)
    employees_data.append({
        "employee_code": "NV002",
        "username": "manager1",
        "hashed_password": get_password_hash("testpassword"),
        "full_name": "Lê Minh Đức",
        "email": "manager1@ecommercekpi.com",
        "role": Role.MANAGER.value,
        "status": EmployeeStatus.ACTIVE.value,
        "platforms": [Platform.SHOPEE.value, Platform.LAZADA.value],
        "created_at": datetime.now(timezone.utc) - timedelta(days=360),
        "updated_at": datetime.now(timezone.utc) - timedelta(days=360)
    })
    # Manager 2 (NV003)
    employees_data.append({
        "employee_code": "NV003",
        "username": "manager2",
        "hashed_password": get_password_hash("testpassword"),
        "full_name": "Trần Thu Thảo",
        "email": "manager2@ecommercekpi.com",
        "role": Role.MANAGER.value,
        "status": EmployeeStatus.ACTIVE.value,
        "platforms": [Platform.TIKTOK.value, Platform.TIKI.value],
        "created_at": datetime.now(timezone.utc) - timedelta(days=350),
        "updated_at": datetime.now(timezone.utc) - timedelta(days=350)
    })
    # Manager 3 (NV004)
    employees_data.append({
        "employee_code": "NV004",
        "username": "manager3",
        "hashed_password": get_password_hash("testpassword"),
        "full_name": "Phan Hữu Tiến",
        "email": "manager3@ecommercekpi.com",
        "role": Role.MANAGER.value,
        "status": EmployeeStatus.ACTIVE.value,
        "platforms": [Platform.SHOPEE.value, Platform.TIKTOK.value],
        "created_at": datetime.now(timezone.utc) - timedelta(days=340),
        "updated_at": datetime.now(timezone.utc) - timedelta(days=340)
    })
    # Employee/Testuser (NV005)
    employees_data.append({
        "employee_code": "NV005",
        "username": "testuser",
        "hashed_password": get_password_hash("testpassword"),
        "full_name": "Phạm Nam Anh",
        "email": "testuser@ecommercekpi.com",
        "role": Role.EMPLOYEE.value,
        "status": EmployeeStatus.ACTIVE.value,
        "platforms": [Platform.SHOPEE.value, Platform.LAZADA.value],
        "created_at": datetime.now(timezone.utc) - timedelta(days=330),
        "updated_at": datetime.now(timezone.utc) - timedelta(days=330)
    })

    # Generate remaining 15 employees (NV006 to NV020)
    emp_names = generate_vietnamese_names(15)
    platforms_pool = [
        [Platform.SHOPEE.value],
        [Platform.LAZADA.value],
        [Platform.TIKTOK.value],
        [Platform.TIKI.value],
        [Platform.SHOPEE.value, Platform.LAZADA.value],
        [Platform.TIKTOK.value, Platform.TIKI.value],
        [Platform.SHOPEE.value, Platform.TIKTOK.value],
        [Platform.LAZADA.value, Platform.TIKI.value]
    ]

    for idx in range(15):
        code = f"NV{idx+6:03d}"
        username = f"employee{idx+2}"
        name = emp_names[idx]
        email = f"{username}@ecommercekpi.com"
        platforms_assigned = platforms_pool[idx % len(platforms_pool)]
        # Mark the last employee as Inactive to show status variations
        status = EmployeeStatus.INACTIVE.value if idx == 14 else EmployeeStatus.ACTIVE.value
        
        employees_data.append({
            "employee_code": code,
            "username": username,
            "hashed_password": get_password_hash("testpassword"),
            "full_name": name,
            "email": email,
            "role": Role.EMPLOYEE.value,
            "status": status,
            "platforms": platforms_assigned,
            "created_at": datetime.now(timezone.utc) - timedelta(days=300 - idx * 5),
            "updated_at": datetime.now(timezone.utc) - timedelta(days=300 - idx * 5)
        })

    inserted_emps = db["employees"].insert_many(employees_data)
    employee_ids = inserted_emps.inserted_ids
    # Fetch employees to have mappings
    all_employees = list(db["employees"].find())
    print(f"Successfully seeded {len(all_employees)} employees.")

    # Divide staff into managers/employees who can confirm orders
    staff_employees = [emp for emp in all_employees if emp["role"] in [Role.MANAGER.value, Role.EMPLOYEE.value]]
    staff_ids = [emp["_id"] for emp in staff_employees]

    # 3. Generate Master Customer Pool (500)
    print("\nGenerating 500 customers...")
    cust_names = generate_vietnamese_names(500)
    cust_phones = generate_vietnamese_phones(500)
    customers = []
    for i in range(500):
        customers.append({
            "customer_id": f"CUST-{i+1:04d}",
            "customer_name": cust_names[i],
            "customer_phone": cust_phones[i]
        })
    print("Customer pool created in memory.")

    # 4. Generate 5000 Orders
    print("\nGenerating 5000 orders...")
    orders_data = []
    
    # Distribute dates: 3000 in the last 50 days (scaling), 2000 in the first 315 days
    now = datetime.now(timezone.utc)
    order_dates = []
    for _ in range(2000):
        days_ago = random.uniform(50, 365)
        order_dates.append(now - timedelta(days=days_ago))
    for _ in range(3000):
        days_ago = random.uniform(0, 50)
        order_dates.append(now - timedelta(days=days_ago))
    
    # Chronological sort for correct sequential order IDs
    order_dates.sort()

    # Track customer stats in memory to construct blacklist dynamically later
    customer_stats = {}
    for c in customers:
        customer_stats[c["customer_id"]] = {
            "customer_id": c["customer_id"],
            "customer_name": c["customer_name"],
            "customer_phone": c["customer_phone"],
            "total_orders": 0,
            "cancelled_orders": 0,
            "returned_orders": 0,
            "last_order_at": None,
            "platform": None
        }

    platforms_all = [Platform.SHOPEE.value, Platform.LAZADA.value, Platform.TIKTOK.value, Platform.TIKI.value]

    for idx, order_date in enumerate(order_dates):
        # Pick a customer
        cust_idx = random.randint(0, 499)
        cust = customers[cust_idx]
        
        # Pick confirming employee
        emp = random.choice(staff_employees)
        emp_id = emp["_id"]
        
        # Pick a platform assigned to this employee
        emp_platforms = emp["platforms"]
        if Platform.ALL.value in emp_platforms or not emp_platforms:
            platform = random.choice(platforms_all)
        else:
            platform = random.choice(emp_platforms)
            
        # Determine order status:
        # First 100 customers (indices 0 to 99) are destined for blacklist
        # They get abnormally high cancel and return rates
        is_blacklist_candidate = (cust_idx < 100)
        
        days_ago = (now - order_date).days
        
        if is_blacklist_candidate:
            # 20% Completed, 50% Cancelled, 30% Returned
            status = random.choices(
                [OrderStatus.COMPLETED.value, OrderStatus.CANCELLED.value, OrderStatus.RETURNED.value],
                weights=[0.20, 0.50, 0.30],
                k=1
            )[0]
        else:
            # Normal distribution: Completed, Cancelled, Returned, Late, and small Pending for last 2 days
            if days_ago <= 2:
                status = random.choices(
                    [OrderStatus.COMPLETED.value, OrderStatus.CANCELLED.value, OrderStatus.RETURNED.value, OrderStatus.LATE.value, OrderStatus.PENDING.value],
                    weights=[0.90, 0.04, 0.01, 0.01, 0.04],
                    k=1
                )[0]
            else:
                status = random.choices(
                    [OrderStatus.COMPLETED.value, OrderStatus.CANCELLED.value, OrderStatus.RETURNED.value, OrderStatus.LATE.value],
                    weights=[0.94, 0.04, 0.015, 0.005],
                    k=1
                )[0]
                
        total_amount = Decimal(f"{random.uniform(50000.0, 3000000.0):.2f}")
        
        # Reasons
        cancel_reason = None
        if status == OrderStatus.CANCELLED.value:
            cancel_reason = random.choice(["Out of stock", "Customer cancelled", "Incorrect shipping address", "Payment failed", "Delivery partner delay"])
            
        return_reason = None
        if status == OrderStatus.RETURNED.value:
            return_reason = random.choice(["Damaged item", "Wrong size", "Defective product", "Changed mind", "Not as described"])

        # Timestamps
        confirmed_at = order_date + timedelta(minutes=random.randint(5, 60)) if status != OrderStatus.PENDING.value else None
        completed_at = None
        cancelled_at = None
        returned_at = None
        late_at = None
        
        if status == OrderStatus.COMPLETED.value:
            completed_at = confirmed_at + timedelta(days=random.randint(1, 3))
        elif status == OrderStatus.CANCELLED.value:
            cancelled_at = order_date + timedelta(hours=random.randint(1, 12))
        elif status == OrderStatus.RETURNED.value:
            completed_at = confirmed_at + timedelta(days=random.randint(1, 3))
            returned_at = completed_at + timedelta(days=random.randint(1, 4))
        elif status == OrderStatus.LATE.value:
            late_at = confirmed_at + timedelta(days=random.randint(3, 5))

        order_doc = {
            "order_id": f"ORD-{order_date.strftime('%Y%m%d')}-{idx+1:05d}",
            "platform": platform,
            "customer_id": cust["customer_id"],
            "customer_name": cust["customer_name"],
            "customer_phone": cust["customer_phone"],
            "confirmed_by": emp_id,
            "total_amount": total_amount,
            "status": status,
            "cancel_reason": cancel_reason,
            "return_reason": return_reason,
            "confirmed_at": confirmed_at,
            "completed_at": completed_at,
            "cancelled_at": cancelled_at,
            "returned_at": returned_at,
            "late_at": late_at,
            "created_at": order_date,
            "updated_at": max(filter(None, [order_date, confirmed_at, completed_at, cancelled_at, returned_at, late_at]))
        }
        
        orders_data.append(order_doc)
        
        # Update customer metrics
        stats = customer_stats[cust["customer_id"]]
        stats["total_orders"] += 1
        if status == OrderStatus.CANCELLED.value:
            stats["cancelled_orders"] += 1
        elif status == OrderStatus.RETURNED.value:
            stats["returned_orders"] += 1
            
        if stats["last_order_at"] is None or order_date > stats["last_order_at"]:
            stats["last_order_at"] = order_date
            stats["platform"] = platform

    db["orders"].insert_many(orders_data)
    print(f"Successfully seeded 5000 orders.")

    # 5. Seed 100 Blacklist Records
    print("\nGenerating 100 blacklist records...")
    blacklist_data = []
    # Take the first 100 customers who had high cancel/return rates
    for i in range(100):
        c = customers[i]
        stats = customer_stats[c["customer_id"]]
        total = stats["total_orders"]
        cancelled = stats["cancelled_orders"]
        returned = stats["returned_orders"]
        
        if total > 0:
            risk_score = min(100.0, float(cancelled + returned) / total * 100.0)
        else:
            risk_score = random.uniform(30.0, 60.0)
            
        # Determine risk level
        if risk_score >= 75:
            risk_level = RiskLevel.BLACKLIST.value
        elif risk_score >= 50:
            risk_level = RiskLevel.HIGH.value
        elif risk_score >= 25:
            risk_level = RiskLevel.MEDIUM.value
        else:
            risk_level = RiskLevel.LOW.value

        blacklist_date = stats["last_order_at"] or (now - timedelta(days=random.randint(1, 10)))
        
        blacklist_data.append({
            "customer_id": c["customer_id"],
            "platform": stats["platform"] or random.choice(platforms_all),
            "customer_name": c["customer_name"],
            "customer_phone": c["customer_phone"],
            "total_orders": total,
            "cancelled_orders": cancelled,
            "returned_orders": returned,
            "risk_score": round(risk_score, 2),
            "risk_level": risk_level,
            "last_order_at": blacklist_date,
            "added_at": blacklist_date + timedelta(minutes=random.randint(15, 180)),
            "created_at": blacklist_date,
            "updated_at": blacklist_date
        })

    db["customer_blacklist"].insert_many(blacklist_data)
    print(f"Successfully seeded 100 customer blacklist records.")

    # 6. Seed exactly 1000 daily Revenues
    # We will generate daily revenues for each of the 20 employees over the last 50 days (20 * 50 = 1000 records)
    print("\nGenerating 1000 daily revenues...")
    revenues_data = []
    
    # Pre-aggregate orders in memory to group by (employee_id, platform, date)
    orders_by_emp_plat_date = {}
    for o in orders_data:
        emp_id = o["confirmed_by"]
        platform = o["platform"]
        o_date = o["created_at"].replace(hour=0, minute=0, second=0, microsecond=0)
        
        key = (emp_id, platform, o_date)
        if key not in orders_by_emp_plat_date:
            orders_by_emp_plat_date[key] = []
        orders_by_emp_plat_date[key].append(o)

    for day_idx in range(50):
        record_date = (now - timedelta(days=day_idx)).replace(hour=0, minute=0, second=0, microsecond=0)
        
        for emp in all_employees:
            emp_id = emp["_id"]
            emp_platforms = emp["platforms"]
            
            # Select platform for this employee's daily record
            if Platform.ALL.value in emp_platforms or not emp_platforms:
                # Cycle through all platforms
                platform = platforms_all[day_idx % len(platforms_all)]
            else:
                # Cycle through assigned platforms
                platform = emp_platforms[day_idx % len(emp_platforms)]
                
            # Aggregate actual orders from memory
            key = (emp_id, platform, record_date)
            matching_orders = orders_by_emp_plat_date.get(key, [])
            
            if matching_orders:
                total_orders = len(matching_orders)
                cancelled = sum(1 for o in matching_orders if o["status"] == OrderStatus.CANCELLED.value)
                returned = sum(1 for o in matching_orders if o["status"] == OrderStatus.RETURNED.value)
                successful = total_orders - (cancelled + returned)
                total_rev = sum(o["total_amount"] for o in matching_orders if o["status"] in [OrderStatus.COMPLETED.value, OrderStatus.LATE.value, OrderStatus.PENDING.value])
            else:
                # Baseline for days with no orders to keep charts rich
                total_orders = random.randint(3, 12)
                cancelled = random.randint(0, 1)
                returned = random.randint(0, 1)
                successful = total_orders - (cancelled + returned)
                total_rev = Decimal(f"{successful * random.uniform(100000.0, 500000.0):.2f}")
                
            target_rev = Decimal(f"{random.uniform(1000000.0, 4000000.0):.2f}")
            
            revenues_data.append({
                "employee_id": emp_id,
                "platform": platform,
                "date": record_date,
                "period": Period.DAILY.value,
                "total_orders": total_orders,
                "successful_orders": successful,
                "returned_orders": returned,
                "cancelled_orders": cancelled,
                "total_revenue": total_rev,
                "target_revenue": target_rev,
                "created_at": record_date,
                "updated_at": record_date
            })

    db["revenues"].insert_many(revenues_data)
    print(f"Successfully seeded {len(revenues_data)} revenue records.")

    # 7. Seed 1200 Daily KPI Records (60 days * 20 employees)
    print("\nGenerating 1200 daily KPI records...")
    kpi_data = []
    for day_idx in range(60):
        record_date = (now - timedelta(days=day_idx)).replace(hour=0, minute=0, second=0, microsecond=0)
        for emp in all_employees:
            emp_id = emp["_id"]
            
            orders_score = round(random.uniform(22.0, 40.0), 2)
            chats_score = round(random.uniform(12.0, 20.0), 2)
            products_score = round(random.uniform(9.0, 15.0), 2)
            revenue_score = round(random.uniform(15.0, 25.0), 2)
            penalty = round(random.choice([0.0] * 9 + [random.uniform(2.0, 8.0)]), 2)
            
            total_kpi = min(100.0, max(0.0, orders_score + chats_score + products_score + revenue_score - penalty))
            
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
                "employee_id": emp_id,
                "date": record_date,
                "orders_score": orders_score,
                "chats_score": chats_score,
                "products_score": products_score,
                "revenue_score": revenue_score,
                "penalty_deductions": penalty,
                "total_kpi_score": round(total_kpi, 2),
                "classification": cls,
                "details": {"note": "Daily automated batch calculations"},
                "created_at": record_date
            })
            
    db["kpi_daily"].insert_many(kpi_data)
    print(f"Successfully seeded {len(kpi_data)} daily KPI records.")

    # 8. Seed 100 Rewards
    print("\nGenerating 100 rewards...")
    rewards_data = []
    reward_statuses = [RewardStatus.PENDING.value, RewardStatus.APPROVED.value, RewardStatus.PAID.value]
    
    for i in range(100):
        emp = random.choice(all_employees)
        reward_date = now - timedelta(days=random.randint(1, 350))
        
        rewards_data.append({
            "employee_id": emp["_id"],
            "date": reward_date,
            "period": random.choice([Period.DAILY.value, Period.MONTHLY.value]),
            "kpi_score": round(random.uniform(70.0, 100.0), 2),
            "reward_amount": Decimal(f"{random.uniform(100000.0, 4000000.0):.2f}"),
            "currency": "VND",
            "status": random.choice(reward_statuses),
            "created_at": reward_date,
            "updated_at": reward_date
        })
        
    db["rewards"].insert_many(rewards_data)
    print(f"Successfully seeded 100 rewards.")

    # 9. Seed 100 Notifications
    print("\nGenerating 100 notifications...")
    notifications_data = []
    notif_types = [NotificationType.KPI_ALERT.value, NotificationType.BLACKLIST_ALERT.value, NotificationType.SYSTEM.value]
    titles = {
        NotificationType.KPI_ALERT.value: ["Daily KPI Target Achieved!", "KPI Score Fall Warning", "Weekly Review Pending", "Outstanding Performance Awarded"],
        NotificationType.BLACKLIST_ALERT.value: ["New Blacklist Customer Alert", "Fraudulent Order Blocked", "Blacklist Sync Complete", "High Risk Activity Detected"],
        NotificationType.SYSTEM.value: ["System Maintenance Notice", "Database Update Completed", "Monthly Review Schedule", "Security Rules Updated"]
    }
    
    for i in range(100):
        notif_date = now - timedelta(days=random.randint(0, 360))
        ntype = random.choice(notif_types)
        title = random.choice(titles[ntype])
        body = f"Detailed notification payload for {title.lower()} generated at {notif_date.strftime('%Y-%m-%d %H:%M:%S')}"
        emp = random.choice(all_employees)
        
        notifications_data.append({
            "recipient_role": random.choice([Role.ADMIN.value, Role.MANAGER.value, Role.EMPLOYEE.value, None]),
            "recipient_id": emp["_id"] if random.choice([True, False]) else None,
            "title": title,
            "body": body,
            "type": ntype,
            "is_read": random.choice([True, False]),
            "created_at": notif_date
        })
        
    db["notifications"].insert_many(notifications_data)
    print(f"Successfully seeded 100 notifications.")

    # 10. Seed 50 Reports
    print("\nGenerating 50 reports...")
    reports_data = []
    report_types = [ReportType.DAILY_EMAIL.value, ReportType.MONTHLY_SUMMARY.value]
    report_sent_statuses = [ReportSentStatus.SENT.value] * 9 + [ReportSentStatus.FAILED.value]
    
    for i in range(50):
        report_date = now - timedelta(days=random.randint(1, 350))
        r_type = random.choice(report_types)
        successful_orders = random.randint(200, 2000)
        total_revenue = Decimal(f"{successful_orders * random.uniform(150000.0, 450000.0):.2f}")
        top_emp = random.choice(all_employees)["full_name"]
        
        reports_data.append({
            "report_type": r_type,
            "date": report_date,
            "recipients": ["admin@ecommercekpi.com", "manager1@ecommercekpi.com", "manager2@ecommercekpi.com"],
            "total_revenue": total_revenue,
            "total_orders": successful_orders,
            "top_employee": top_emp,
            "new_blacklist_count": random.randint(0, 10),
            "summary_data": {"note": "Generated automatically by system report cron jobs"},
            "sent_status": random.choice(report_sent_statuses),
            "created_at": report_date
        })
        
    db["reports"].insert_many(reports_data)
    print(f"Successfully seeded 50 reports.")

    # 11. Seed 100 Product Activities (Auxiliary)
    print("\nGenerating 100 product activities...")
    activities_data = []
    act_types = [ProductActivityType.CREATE.value, ProductActivityType.UPDATE.value]
    
    for idx in range(100):
        act_date = now - timedelta(days=random.randint(0, 30))
        emp = random.choice(staff_employees)
        emp_platforms = emp["platforms"]
        platform = random.choice(emp_platforms) if emp_platforms and Platform.ALL.value not in emp_platforms else random.choice(platforms_all)
        
        activities_data.append({
            "employee_id": emp["_id"],
            "platform": platform,
            "product_id": f"PROD-{random.randint(100000, 999999)}",
            "activity_type": random.choice(act_types),
            "timestamp": act_date,
            "created_at": act_date
        })
        
    db["product_activities"].insert_many(activities_data)
    print(f"Successfully seeded 100 product activities.")

    # 12. Seed 100 Audit Logs (Auxiliary)
    print("\nGenerating 100 audit logs...")
    audit_data = []
    actions = [AuditAction.UPDATE_KPI_RULE.value, AuditAction.UPDATE_REWARD_RULE.value, AuditAction.CREATE_EMPLOYEE.value, AuditAction.DELETE_EMPLOYEE.value, AuditAction.BLACKLIST_CUSTOMER.value]
    entities = {
        AuditAction.UPDATE_KPI_RULE.value: ("kpi_rules", "RULE-KPI-01"),
        AuditAction.UPDATE_REWARD_RULE.value: ("reward_rules", "RULE-REW-02"),
        AuditAction.CREATE_EMPLOYEE.value: ("employees", "NV021"),
        AuditAction.DELETE_EMPLOYEE.value: ("employees", "NV022"),
        AuditAction.BLACKLIST_CUSTOMER.value: ("customer_blacklist", "CUST-0099")
    }
    
    for i in range(100):
        log_date = now - timedelta(days=random.randint(1, 300))
        action = random.choice(actions)
        entity_type, entity_id = entities[action]
        emp = random.choice(all_employees)
        
        audit_data.append({
            "user_id": emp["_id"],
            "action": action,
            "entity_type": entity_type,
            "entity_id": entity_id,
            "old_value": {"status": "inactive"},
            "new_value": {"status": "active"},
            "created_at": log_date
        })
        
    db["audit_logs"].insert_many(audit_data)
    print(f"Successfully seeded 100 audit logs.")

    # 13. Seed 2 Active Employee Sessions for immediate dashboard rendering
    print("\nGenerating 2 active employee sessions...")
    session_data = [
        {
            "employee_id": all_employees[0]["_id"], # admin
            "token": "admin-session-demo-token-string",
            "ip_address": "127.0.0.1",
            "user_agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
            "expires_at": now + timedelta(hours=12),
            "last_activity_at": now - timedelta(minutes=5),
            "created_at": now - timedelta(hours=2)
        },
        {
            "employee_id": all_employees[4]["_id"], # testuser
            "token": "employee-session-demo-token-string",
            "ip_address": "127.0.0.1",
            "user_agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
            "expires_at": now + timedelta(hours=12),
            "last_activity_at": now - timedelta(minutes=15),
            "created_at": now - timedelta(hours=1)
        }
    ]
    db["employee_sessions"].insert_many(session_data)
    print(f"Successfully seeded 2 active sessions.")

    # =========================================================================
    # CALCULATE AND DISPLAY FINAL STATS
    # =========================================================================
    print("\n" + "="*50)
    print("DEMO DATA SEEDING COMPLETE")
    print("="*50)
    
    # 1. Records Count
    print("\n1. Record Counts Per Collection:")
    for col in collections_to_clear:
        count = db[col].count_documents({})
        print(f"   - {col:22}: {count}")

    # 2. Estimated Dashboard Metrics
    # Run the exact aggregation logic as the dashboard service
    completed_pipeline = [
        {"$match": {"status": OrderStatus.COMPLETED.value}},
        {"$group": {"_id": None, "total": {"$sum": "$total_amount"}}}
    ]
    completed_res = list(db["orders"].aggregate(completed_pipeline))
    tot_rev = completed_res[0]["total"] if completed_res else Decimal("0.00")
    if isinstance(tot_rev, Decimal128):
        tot_rev = tot_rev.to_decimal()
        
    tot_orders = db["orders"].count_documents({})
    completed_orders = db["orders"].count_documents({"status": OrderStatus.COMPLETED.value})
    avg_order_val = tot_rev / completed_orders if completed_orders > 0 else Decimal("0.00")
    
    # Risk average
    blacklist_pipeline = [
        {"$group": {"_id": None, "avg_risk": {"$avg": "$risk_score"}}}
    ]
    blacklist_res = list(db["customer_blacklist"].aggregate(blacklist_pipeline))
    avg_risk = blacklist_res[0]["avg_risk"] if blacklist_res else 0.0

    # Platform distribution
    platform_pipeline = [
        {"$group": {"_id": "$platform", "count": {"$sum": 1}}},
        {"$sort": {"count": -1}}
    ]
    platform_res = list(db["orders"].aggregate(platform_pipeline))

    print("\n2. Estimated Dashboard Metrics:")
    print(f"   - Total Orders                     : {tot_orders}")
    print(f"   - Completed Orders                 : {completed_orders}")
    print(f"   - Total Revenue (Completed Orders) : {tot_rev:,.2f} VND")
    print(f"   - Average Completed Order Value    : {avg_order_val:,.2f} VND")
    print(f"   - Total Seeded Employees           : {db['employees'].count_documents({})}")
    print(f"   - Active Sessions                  : {db['employee_sessions'].count_documents({'expires_at': {'$gt': now}})}")
    print(f"   - Blacklisted Customers            : {db['customer_blacklist'].count_documents({})}")
    print(f"   - Average Risk Score (Blacklist)   : {avg_risk:.2f}%")
    print(f"   - Order Platform Distribution:")
    for plat in platform_res:
        plat_name = plat["_id"]
        plat_count = plat["count"]
        pct = (plat_count / tot_orders) * 100
        print(f"     * {plat_name:15}: {plat_count} ({pct:.2f}%)")

    client.close()

if __name__ == "__main__":
    seed_database()
