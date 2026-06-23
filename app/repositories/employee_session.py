from datetime import datetime, timezone
from typing import Optional
from motor.motor_asyncio import AsyncIOMotorCollection
from app.repositories.base import BaseRepository
from app.models.base import PyObjectId
from app.models.employee_session import EmployeeSession
from app.schemas.employee_session import EmployeeSessionCreate, EmployeeSessionUpdate


class EmployeeSessionRepository(BaseRepository[EmployeeSession, EmployeeSessionCreate, EmployeeSessionUpdate]):
    """
    Concrete Repository class for executing operations on the 'employee_sessions' collection.
    """
    def __init__(self, collection: AsyncIOMotorCollection):
        super().__init__(collection, EmployeeSession)

    async def find_active_session(self, session_id: str) -> Optional[EmployeeSession]:
        """Find an active login session, validating expiration timestamp."""
        current_time = datetime.now(timezone.utc)
        return await self.find_one({
            "session_id": session_id,
            "expires_at": {"$gt": current_time}
        })

    async def revoke_session(self, session_id: str) -> bool:
        """Revoke/delete a specific login session."""
        result = await self.collection.delete_one({"session_id": session_id})
        return result.deleted_count > 0

    async def revoke_all_sessions(self, employee_id: PyObjectId) -> int:
        """Delete all login sessions associated with an employee."""
        result = await self.collection.delete_many({"employee_id": employee_id})
        return result.deleted_count
