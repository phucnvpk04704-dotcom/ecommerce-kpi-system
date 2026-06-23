from datetime import datetime
from app.services.base import BaseService
from app.models.base import PyObjectId
from app.models.order import Order
from app.repositories.order import OrderRepository


class OrderService(BaseService[Order, OrderRepository]):
    """
    Business Service for managing orders and tracking employee performance metrics.
    Delegates database access operations directly to the OrderRepository.
    """
    def __init__(self, order_repository: OrderRepository):
        super().__init__(order_repository)

    async def get_employee_order_stats(
        self,
        employee_id: PyObjectId,
        start_date: datetime,
        end_date: datetime
    ) -> dict:
        """
        Aggregate order status counts for a specific employee within a date range.
        Reuses repository.get_employee_order_stats().
        """
        return await self.repository.get_employee_order_stats(
            employee_id=employee_id,
            start_date=start_date,
            end_date=end_date
        )

    async def count_customer_orders_by_status(
        self,
        customer_id: str,
        platform: str
    ) -> dict:
        """
        Aggregate order counts by status for a specific customer on a platform.
        Reuses repository.count_customer_orders_by_status().
        """
        return await self.repository.count_customer_orders_by_status(
            customer_id=customer_id,
            platform=platform
        )

    async def count_customer_orders_by_phone(
        self,
        customer_phone: str,
        platform: str
    ) -> dict:
        """
        Aggregate order counts by status for a specific customer phone number on a platform.
        Reuses repository.count_customer_orders_by_phone().
        """
        return await self.repository.count_customer_orders_by_phone(
            customer_phone=customer_phone,
            platform=platform
        )
