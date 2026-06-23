from datetime import datetime
from app.services.base import BaseService
from app.models.base import PyObjectId
from app.models.product_activity import ProductActivity
from app.repositories.product_activity import ProductActivityRepository


class ProductActivityService(BaseService[ProductActivity, ProductActivityRepository]):
    """
    Business Service for managing product updates/posts and other store management operations.
    Delegates database access operations directly to the ProductActivityRepository.
    """
    def __init__(self, product_activity_repository: ProductActivityRepository):
        super().__init__(product_activity_repository)

    async def get_employee_activity_count(
        self,
        employee_id: PyObjectId,
        start_date: datetime,
        end_date: datetime,
        activity_type: str
    ) -> int:
        """
        Count logged product activities of a specific type for an employee in a date range.
        Reuses repository.get_employee_activity_count().
        """
        return await self.repository.get_employee_activity_count(
            employee_id=employee_id,
            start_date=start_date,
            end_date=end_date,
            activity_type=activity_type
        )
