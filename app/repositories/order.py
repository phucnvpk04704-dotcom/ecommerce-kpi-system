from datetime import datetime
from typing import Dict, Any
from motor.motor_asyncio import AsyncIOMotorCollection
from app.repositories.base import BaseRepository
from app.models.base import PyObjectId
from app.models.order import Order
from app.schemas.order import OrderCreate, OrderUpdate
from app.core.enums.order import OrderStatus


class OrderRepository(BaseRepository[Order, OrderCreate, OrderUpdate]):
    """
    Concrete Repository class for executing operations on the 'orders' collection.
    """
    def __init__(self, collection: AsyncIOMotorCollection):
        super().__init__(collection, Order)

    async def get_employee_order_stats(
        self,
        employee_id: PyObjectId,
        start_date: datetime,
        end_date: datetime
    ) -> dict:
        """
        Aggregate order status counts for a specific employee within a date range.
        Returns:
            {"completed": int, "cancelled": int, "returned": int, "late": int, "total": int}
        """
        pipeline = [
            {
                "$match": {
                    "confirmed_by": employee_id,
                    "created_at": {"$gte": start_date, "$lte": end_date}
                }
            },
            {
                "$group": {
                    "_id": None,
                    "total": {"$sum": 1},
                    "completed": {
                        "$sum": {"$cond": [{"$eq": ["$status", OrderStatus.COMPLETED.value]}, 1, 0]}
                    },
                    "cancelled": {
                        "$sum": {"$cond": [{"$eq": ["$status", OrderStatus.CANCELLED.value]}, 1, 0]}
                    },
                    "returned": {
                        "$sum": {"$cond": [{"$eq": ["$status", OrderStatus.RETURNED.value]}, 1, 0]}
                    },
                    "late": {
                        "$sum": {"$cond": [{"$eq": ["$status", OrderStatus.LATE.value]}, 1, 0]}
                    }
                }
            }
        ]
        
        cursor = self.collection.aggregate(pipeline)
        results = await cursor.to_list(length=1)
        
        if not results:
            return {
                "completed": 0,
                "cancelled": 0,
                "returned": 0,
                "late": 0,
                "total": 0
            }
            
        summary = results[0]
        return {
            "completed": summary.get("completed", 0),
            "cancelled": summary.get("cancelled", 0),
            "returned": summary.get("returned", 0),
            "late": summary.get("late", 0),
            "total": summary.get("total", 0)
        }

    async def count_customer_orders_by_status(
        self,
        customer_id: str,
        platform: str
    ) -> dict:
        """
        Aggregate order counts by status for a specific customer on a platform.
        Returns:
            {"total_orders": int, "cancelled_orders": int, "returned_orders": int}
        """
        pipeline = [
            {
                "$match": {
                    "customer_id": customer_id,
                    "platform": platform
                }
            },
            {
                "$group": {
                    "_id": None,
                    "total_orders": {"$sum": 1},
                    "cancelled_orders": {
                        "$sum": {"$cond": [{"$eq": ["$status", OrderStatus.CANCELLED.value]}, 1, 0]}
                    },
                    "returned_orders": {
                        "$sum": {"$cond": [{"$eq": ["$status", OrderStatus.RETURNED.value]}, 1, 0]}
                    }
                }
            }
        ]
        
        cursor = self.collection.aggregate(pipeline)
        results = await cursor.to_list(length=1)
        
        if not results:
            return {
                "total_orders": 0,
                "cancelled_orders": 0,
                "returned_orders": 0
            }
            
        summary = results[0]
        return {
            "total_orders": summary.get("total_orders", 0),
            "cancelled_orders": summary.get("cancelled_orders", 0),
            "returned_orders": summary.get("returned_orders", 0)
        }

    async def count_customer_orders_by_phone(
        self,
        customer_phone: str,
        platform: str
    ) -> dict:
        """
        Aggregate order counts by status for a specific customer phone number on a platform.
        Returns:
            {"total_orders": int, "cancelled_orders": int, "returned_orders": int}
        """
        pipeline = [
            {
                "$match": {
                    "customer_phone": customer_phone,
                    "platform": platform
                }
            },
            {
                "$group": {
                    "_id": None,
                    "total_orders": {"$sum": 1},
                    "cancelled_orders": {
                        "$sum": {"$cond": [{"$eq": ["$status", OrderStatus.CANCELLED.value]}, 1, 0]}
                    },
                    "returned_orders": {
                        "$sum": {"$cond": [{"$eq": ["$status", OrderStatus.RETURNED.value]}, 1, 0]}
                    }
                }
            }
        ]
        
        cursor = self.collection.aggregate(pipeline)
        results = await cursor.to_list(length=1)
        
        if not results:
            return {
                "total_orders": 0,
                "cancelled_orders": 0,
                "returned_orders": 0
            }
            
        summary = results[0]
        return {
            "total_orders": summary.get("total_orders", 0),
            "cancelled_orders": summary.get("cancelled_orders", 0),
            "returned_orders": summary.get("returned_orders", 0)
        }
