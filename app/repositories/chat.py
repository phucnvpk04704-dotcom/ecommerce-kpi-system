from datetime import datetime
from typing import Optional
from motor.motor_asyncio import AsyncIOMotorCollection
from app.repositories.base import BaseRepository
from app.models.base import PyObjectId
from app.models.chat import Chat
from app.schemas.chat import ChatCreate, ChatUpdate


class ChatRepository(BaseRepository[Chat, ChatCreate, ChatUpdate]):
    """
    Concrete Repository class for executing operations on the 'chats' collection.
    """
    def __init__(self, collection: AsyncIOMotorCollection):
        super().__init__(collection, Chat)

    async def get_employee_chat_stats(
        self,
        employee_id: PyObjectId,
        date: datetime
    ) -> Optional[Chat]:
        """Query daily chat metric aggregates for a specific employee on a given date."""
        return await self.find_one({
            "employee_id": employee_id,
            "date": date
        })
