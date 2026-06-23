from typing import Optional, List
from motor.motor_asyncio import AsyncIOMotorCollection
from app.repositories.base import BaseRepository
from app.models.employee import Employee
from app.schemas.employee import EmployeeCreate, EmployeeUpdate


class EmployeeRepository(BaseRepository[Employee, EmployeeCreate, EmployeeUpdate]):
    """
    Concrete Repository class for executing operations on the 'employees' collection.
    """
    def __init__(self, collection: AsyncIOMotorCollection):
        super().__init__(collection, Employee)

    async def find_by_username(self, username: str) -> Optional[Employee]:
        """Retrieve an employee profile matching the username key."""
        return await self.find_one({"username": username})

    async def find_by_employee_code(self, employee_code: str) -> Optional[Employee]:
        """Retrieve an employee profile matching the unique employee code."""
        return await self.find_one({"employee_code": employee_code})

    async def find_by_platform(
        self, platform: str, skip: int = 0, limit: int = 100
    ) -> List[Employee]:
        """Filter employees who are active on a specific ecommerce marketplace."""
        return await self.find_many({"platforms": platform}, skip=skip, limit=limit)
