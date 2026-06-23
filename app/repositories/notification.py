from typing import List, Optional
from motor.motor_asyncio import AsyncIOMotorCollection
from app.repositories.base import BaseRepository
from app.models.base import PyObjectId
from app.models.notification import Notification
from app.schemas.notification import NotificationCreate, NotificationUpdate
from app.core.enums.employee import Role


class NotificationRepository(BaseRepository[Notification, NotificationCreate, NotificationUpdate]):
    """
    Concrete Repository class for executing operations on the 'notifications' collection.
    """
    def __init__(self, collection: AsyncIOMotorCollection):
        super().__init__(collection, Notification)

    async def get_unread_by_user(self, recipient_id: PyObjectId) -> List[Notification]:
        """Retrieve unread notifications for a specific employee, sorted newest first."""
        return await self.find_many(
            filter={
                "recipient_id": recipient_id,
                "is_read": False
            },
            limit=500,
            sort=[("created_at", -1)]
        )

    async def get_unread_by_role(self, role: Role) -> List[Notification]:
        """Retrieve unread notifications targeted at a specific role group, sorted newest first."""
        return await self.find_many(
            filter={
                "recipient_role": role,
                "is_read": False
            },
            limit=500,
            sort=[("created_at", -1)]
        )
