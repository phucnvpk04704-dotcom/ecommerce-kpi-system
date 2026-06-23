from typing import Optional
from app.services.base import BaseService
from app.models.base import PyObjectId
from app.models.employee_session import EmployeeSession
from app.repositories.employee_session import EmployeeSessionRepository


class EmployeeSessionService(BaseService[EmployeeSession, EmployeeSessionRepository]):
    """
    Business Service for managing employee login sessions.
    Delegates database access operations directly to the EmployeeSessionRepository.
    """
    def __init__(self, employee_session_repository: EmployeeSessionRepository):
        super().__init__(employee_session_repository)

    async def get_active_session(self, session_id: str) -> Optional[EmployeeSession]:
        """
        Return active session matching the session ID.
        Reuses repository.find_active_session().
        """
        return await self.repository.find_active_session(session_id)

    async def revoke_session(self, session_id: str) -> bool:
        """
        Revoke a single session by session ID.
        Reuses repository.revoke_session().
        """
        return await self.repository.revoke_session(session_id)

    async def revoke_all_employee_sessions(self, employee_id: PyObjectId) -> int:
        """
        Revoke all sessions for a specific employee.
        Reuses repository.revoke_all_sessions().
        """
        return await self.repository.revoke_all_sessions(employee_id)
