from datetime import datetime
from motor.motor_asyncio import AsyncIOMotorCollection
from app.repositories.base import BaseRepository
from app.models.base import PyObjectId
from app.models.product_activity import ProductActivity
from app.schemas.product_activity import ProductActivityCreate, ProductActivityUpdate


class ProductActivityRepository(BaseRepository[ProductActivity, ProductActivityCreate, ProductActivityUpdate]):
    """
    Concrete Repository class for executing operations on the 'product_activities' collection.
    """
    def __init__(self, collection: AsyncIOMotorCollection):
        super().__init__(collection, ProductActivity)

    async def get_employee_activity_count(
        self,
        employee_id: PyObjectId,
        start_date: datetime,
        end_date: datetime,
        activity_type: str
    ) -> int:
        """Count logged product activities of a specific type for an employee in a date range."""
        return await self.count({
            "employee_id": employee_id,
            "activity_type": activity_type,
            "timestamp": {
                "$gte": start_date,
                "$lte": end_date
            }
        })
