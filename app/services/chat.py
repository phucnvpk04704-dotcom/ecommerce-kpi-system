from datetime import datetime
from typing import Optional
from app.services.base import BaseService
from app.models.base import PyObjectId
from app.models.chat import Chat
from app.repositories.chat import ChatRepository


class ChatService(BaseService[Chat, ChatRepository]):
    """
    Business Service for managing daily chat conversation metrics.
    Delegates database access operations directly to the ChatRepository.
    """
    def __init__(self, chat_repository: ChatRepository):
        super().__init__(chat_repository)

    async def get_employee_chat_stats(
        self,
        employee_id: PyObjectId,
        date: datetime
    ) -> Optional[Chat]:
        """
        Retrieve daily chat metrics for a specific employee on a given date.
        Reuses repository.get_employee_chat_stats().
        """
        return await self.repository.get_employee_chat_stats(
            employee_id=employee_id,
            date=date
        )
