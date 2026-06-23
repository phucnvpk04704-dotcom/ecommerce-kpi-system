from datetime import datetime
from app.services.base import BaseService
from app.models.base import PyObjectId
from app.models.revenue import Revenue
from app.repositories.revenue import RevenueRepository


class RevenueService(BaseService[Revenue, RevenueRepository]):
    """
    Business Service for managing employee revenues.
    Delegates database access operations directly to the RevenueRepository.
    """
    def __init__(self, revenue_repository: RevenueRepository):
        super().__init__(revenue_repository)

    async def get_employee_revenue_stats(
        self,
        employee_id: PyObjectId,
        platform: str,
        start_date: datetime,
        end_date: datetime
    ) -> dict:
        """
        Retrieve aggregated revenue statistics for an employee.
        Reuses repository.get_employee_revenue_stats().
        """
        return await self.repository.get_employee_revenue_stats(
            employee_id=employee_id,
            platform=platform,
            start_date=start_date,
            end_date=end_date
        )
