from typing import Optional
from motor.motor_asyncio import AsyncIOMotorCollection
from app.repositories.base import BaseRepository
from app.models.setting import Setting
from app.schemas.setting import SettingCreate, SettingUpdate


class SettingRepository(BaseRepository[Setting, SettingCreate, SettingUpdate]):
    """
    Concrete Repository class for executing operations on the 'settings' collection.
    """
    def __init__(self, collection: AsyncIOMotorCollection):
        super().__init__(collection, Setting)

    async def find_by_key(self, key: str) -> Optional[Setting]:
        """Find a configuration document matching the unique key."""
        return await self.find_one({"key": key})
