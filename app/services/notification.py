from typing import List, Optional
from app.services.base import BaseService
from app.models.base import PyObjectId
from app.models.notification import Notification
from app.repositories.notification import NotificationRepository
from app.core.enums.employee import Role


class NotificationService(BaseService[Notification, NotificationRepository]):
    """
    Business Service for managing employee notifications.
    Delegates database access operations directly to the NotificationRepository.
    """
    def __init__(self, notification_repository: NotificationRepository):
        super().__init__(notification_repository)

    async def get_unread_by_user(self, recipient_id: PyObjectId) -> List[Notification]:
        """
        Return unread notifications for a specific employee.
        Reuses repository.get_unread_by_user().
        """
        return await self.repository.get_unread_by_user(recipient_id)

    async def get_unread_by_role(self, role: Role) -> List[Notification]:
        """
        Return unread notifications targeted at a specific role.
        Reuses repository.get_unread_by_role().
        """
        return await self.repository.get_unread_by_role(role)

    async def mark_as_read(self, notification_id: str) -> Optional[Notification]:
        """
        Mark a notification as read by setting is_read = True.
        Reuses repository.update().
        """
        return await self.repository.update(notification_id, {"is_read": True})
