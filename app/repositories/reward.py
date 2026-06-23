from datetime import datetime
from typing import List, Optional
from motor.motor_asyncio import AsyncIOMotorCollection
from app.repositories.base import BaseRepository
from app.models.base import PyObjectId
from app.models.reward import Reward
from app.schemas.reward import RewardCreate


class RewardRepository(BaseRepository[Reward, RewardCreate, None]):
    """
    Concrete Repository class for executing operations on the 'rewards' collection.
    """
    def __init__(self, collection: AsyncIOMotorCollection):
        super().__init__(collection, Reward)

    async def get_employee_reward_history(
        self,
        employee_id: PyObjectId,
        start_date: datetime,
        end_date: datetime
    ) -> List[Reward]:
        """Retrieve employee reward history logs over a date range, sorted chronologically."""
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
