from datetime import datetime
from decimal import Decimal
from typing import Dict, Any, Optional
from bson.decimal128 import Decimal128
from motor.motor_asyncio import AsyncIOMotorCollection
from app.repositories.base import BaseRepository
from app.models.base import PyObjectId
from app.models.revenue import Revenue
from app.schemas.revenue import RevenueCreate, RevenueUpdate


class RevenueRepository(BaseRepository[Revenue, RevenueCreate, RevenueUpdate]):
    """
    Concrete Repository class for executing operations on the 'revenues' collection.
    """
    def __init__(self, collection: AsyncIOMotorCollection):
        super().__init__(collection, Revenue)

    async def get_employee_revenue_stats(
        self,
        employee_id: PyObjectId,
        platform: str,
        start_date: datetime,
        end_date: datetime
    ) -> dict:
        """
        Aggregate revenue statistics for a specific employee on a platform within a date range.
        Returns:
            {
                "total_revenue": Decimal,
                "target_revenue": Decimal,
                "total_orders": int,
                "successful_orders": int,
                "returned_orders": int,
                "cancelled_orders": int
            }
        """
        pipeline = [
            {
                "$match": {
                    "employee_id": employee_id,
                    "platform": platform,
                    "date": {"$gte": start_date, "$lte": end_date}
                }
            },
            {
                "$group": {
                    "_id": None,
                    "total_revenue": {"$sum": "$total_revenue"},
                    "target_revenue": {"$sum": "$target_revenue"},
                    "total_orders": {"$sum": "$total_orders"},
                    "successful_orders": {"$sum": "$successful_orders"},
                    "returned_orders": {"$sum": "$returned_orders"},
                    "cancelled_orders": {"$sum": "$cancelled_orders"}
                }
            }
        ]

        cursor = self.collection.aggregate(pipeline)
        results = await cursor.to_list(length=1)

        def to_decimal(val: Any) -> Decimal:
            if isinstance(val, Decimal128):
                return val.to_decimal()
            return Decimal(str(val)) if val is not None else Decimal("0.00")

        if not results:
            return {
                "total_revenue": Decimal("0.00"),
                "target_revenue": Decimal("0.00"),
                "total_orders": 0,
                "successful_orders": 0,
                "returned_orders": 0,
                "cancelled_orders": 0
            }

        summary = results[0]
        return {
            "total_revenue": to_decimal(summary.get("total_revenue")),
            "target_revenue": to_decimal(summary.get("target_revenue")),
            "total_orders": summary.get("total_orders", 0),
            "successful_orders": summary.get("successful_orders", 0),
            "returned_orders": summary.get("returned_orders", 0),
            "cancelled_orders": summary.get("cancelled_orders", 0)
        }
