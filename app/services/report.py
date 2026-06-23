from datetime import datetime
from typing import List, Optional
from app.services.base import BaseService
from app.models.report import Report
from app.repositories.report import ReportRepository
from app.core.enums.report import ReportSentStatus


class ReportService(BaseService[Report, ReportRepository]):
    """
    Business Service for managing system KPI and revenue status reports.
    Delegates database access operations directly to the ReportRepository.
    """
    def __init__(self, report_repository: ReportRepository):
        super().__init__(report_repository)

    async def get_report_by_date(self, date: datetime) -> Optional[Report]:
        """
        Retrieve a report matching a specific reference date.
        Reuses repository.get_report_by_date().
        """
        return await self.repository.get_report_by_date(date)

    async def get_unsent_reports(self) -> List[Report]:
        """
        Retrieve all pending, unsent report documents.
        Reuses repository.get_unsent_reports().
        """
        return await self.repository.get_unsent_reports()

    async def mark_as_sent(self, report_id: str) -> Optional[Report]:
        """
        Mark a specific report as sent by setting its sent status to SENT.
        Reuses repository.update().
        """
        return await self.repository.update(report_id, {"sent_status": ReportSentStatus.SENT})
