from datetime import datetime
from typing import List
from app.services.base import BaseService
from app.models.base import PyObjectId
from app.models.reward import Reward
from app.repositories.reward import RewardRepository
from app.schemas.reward import RewardCreate


class RewardService(BaseService[Reward, RewardRepository]):
    """
    Business Service for managing employee rewards.
    Delegates database access operations directly to the RewardRepository.
    """
    def __init__(self, reward_repository: RewardRepository):
        super().__init__(reward_repository)

    async def get_employee_reward_history(
        self,
        employee_id: PyObjectId,
        start_date: datetime,
        end_date: datetime
    ) -> List[Reward]:
        """
        Retrieve employee reward history logs over a date range.
        Reuses repository.get_employee_reward_history().
        """
        return await self.repository.get_employee_reward_history(
            employee_id=employee_id,
            start_date=start_date,
            end_date=end_date
        )

    async def create_reward_record(self, schema: RewardCreate) -> Reward:
        """
        Create a new reward record in the database.
        Reuses repository.create().
        """
        return await self.repository.create(schema)
