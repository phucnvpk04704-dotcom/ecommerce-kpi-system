from datetime import datetime
from typing import List
from app.services.base import BaseService
from app.models.base import PyObjectId
from app.models.kpi import KPIDaily
from app.repositories.kpi import KPIDailyRepository
from app.schemas.kpi import KPIDailyCreate


class KPIService(BaseService[KPIDaily, KPIDailyRepository]):
    """
    Business Service for managing daily KPI logs.
    Delegates database access operations directly to the KPIDailyRepository.
    """
    def __init__(self, kpi_daily_repository: KPIDailyRepository):
        super().__init__(kpi_daily_repository)

    async def get_employee_kpi_history(
        self,
        employee_id: PyObjectId,
        start_date: datetime,
        end_date: datetime
    ) -> List[KPIDaily]:
        """
        Retrieve employee daily KPI score history logs over a date range.
        Reuses repository.get_employee_kpi_history().
        """
        return await self.repository.get_employee_kpi_history(
            employee_id=employee_id,
            start_date=start_date,
            end_date=end_date
        )

    async def create_kpi_record(self, schema: KPIDailyCreate) -> KPIDaily:
        """
        Create a new KPI daily record in the database.
        Reuses repository.create().
        """
        return await self.repository.create(schema)
