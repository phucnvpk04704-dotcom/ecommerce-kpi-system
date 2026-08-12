from datetime import datetime
from typing import List, Optional
from motor.motor_asyncio import AsyncIOMotorCollection
from app.repositories.base import BaseRepository
from app.models.base import PyObjectId
from app.models.kpi import KPIDaily
from app.schemas.kpi import KPIDailyCreate


class KPIDailyRepository(BaseRepository[KPIDaily, KPIDailyCreate, None]):
    """
    Concrete Repository class for executing operations on the 'kpi_daily' collection.
    """
    def __init__(self, collection: AsyncIOMotorCollection):
        super().__init__(collection, KPIDaily)

    async def get_employee_kpi_history(
        self,
        employee_id: PyObjectId,
        start_date: datetime,
        end_date: datetime
    ) -> List[KPIDaily]:
        """Retrieve employee daily KPI score logs over a date range, sorted chronologically."""
        return await self.find_many(
            filter={
                "employee_id": employee_id,
                "date": {
                    "$gte": start_date,
                    "$lte": end_date
                }
            },
            limit=10000,  # High limit to fetch complete range history without paging truncations
            sort=[("date", 1)]
        )

    async def get_kpi_aggregation(self) -> Optional[dict]:
        """Aggregate KPI scores and penalty points from the entire kpi_daily collection."""
        pipeline = [
            {
                "$group": {
                    "_id": None,
                    "orders_score": {"$avg": "$orders_score"},
                    "chats_score": {"$avg": "$chats_score"},
                    "products_score": {"$avg": "$products_score"},
                    "revenue_score": {"$avg": "$revenue_score"},
                    "penalty_deductions": {"$avg": "$penalty_deductions"},
                    "total_kpi_score": {"$avg": "$total_kpi_score"},
                    "count": {"$sum": 1}
                }
            }
        ]
        res = await self.collection.aggregate(pipeline).to_list(length=1)
        return res[0] if res else None

