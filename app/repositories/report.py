from datetime import datetime
from typing import List, Optional
from motor.motor_asyncio import AsyncIOMotorCollection
from app.repositories.base import BaseRepository
from app.models.report import Report
from app.schemas.report import ReportCreate, ReportUpdate
from app.core.enums.report import ReportSentStatus


class ReportRepository(BaseRepository[Report, ReportCreate, ReportUpdate]):
    """
    Concrete Repository class for executing operations on the 'reports' collection.
    """
    def __init__(self, collection: AsyncIOMotorCollection):
        super().__init__(collection, Report)

    async def get_report_by_date(self, date: datetime) -> Optional[Report]:
        """Find a report document matching the reference calendar date key."""
        return await self.find_one({"date": date})

    async def get_unsent_reports(self) -> List[Report]:
        """Retrieve all reports with a pending status, sorted chronologically by creation date."""
        return await self.find_many(
            filter={"sent_status": ReportSentStatus.PENDING.value},
            limit=1000,
            sort=[("created_at", 1)]
        )
