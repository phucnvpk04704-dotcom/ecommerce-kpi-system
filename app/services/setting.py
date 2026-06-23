from typing import Optional
from app.services.base import BaseService
from app.models.setting import Setting
from app.repositories.setting import SettingRepository


class SettingService(BaseService[Setting, SettingRepository]):
    """
    Business Service for managing global system configurations/settings.
    Delegates database access operations directly to the SettingRepository.
    """
    def __init__(self, setting_repository: SettingRepository):
        super().__init__(setting_repository)

    async def find_by_key(self, key: str) -> Optional[Setting]:
        """
        Retrieve a configuration document by its unique key.
        Reuses repository.find_by_key().
        """
        return await self.repository.find_by_key(key)
