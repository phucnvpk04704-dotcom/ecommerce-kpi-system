from typing import Optional
from app.services.base import BaseService
from app.models.customer_blacklist import CustomerBlacklist
from app.repositories.customer_blacklist import CustomerBlacklistRepository
from app.repositories.order import OrderRepository
from app.core.enums.platform import Platform


class CustomerBlacklistService(BaseService[CustomerBlacklist, CustomerBlacklistRepository]):
    """
    Business Service for managing customer blacklists and evaluating buyer risk factors.
    Delegates database access operations to CustomerBlacklistRepository and OrderRepository.
    """
    def __init__(
        self,
        customer_blacklist_repository: CustomerBlacklistRepository,
        order_repository: OrderRepository
    ):
        super().__init__(customer_blacklist_repository)
        self.order_repository = order_repository

    async def find_by_phone(self, customer_phone: str) -> Optional[CustomerBlacklist]:
        """
        Retrieve a customer blacklist profile by phone number.
        Reuses repository.find_by_phone().
        """
        return await self.repository.find_by_phone(customer_phone)

    async def evaluate_customer_risk(
        self,
        customer_id: str,
        customer_phone: str,
        platform: str
    ) -> Optional[CustomerBlacklist]:
        """
        Retrieve customer order statistics from OrderRepository, calculate the risk score,
        and update the customer's risk level and scores in the blacklist repository.
        """
        # Convert platform to Platform enum
        platform_enum = Platform(platform) if isinstance(platform, str) else platform

        # Get customer order statistics from OrderRepository
        stats = await self.order_repository.count_customer_orders_by_status(
            customer_id=customer_id,
            platform=platform_enum
        )
        total_orders = stats.get("total_orders", 0)
        cancelled_orders = stats.get("cancelled_orders", 0)
        returned_orders = stats.get("returned_orders", 0)

        # Calculate risk score
        if total_orders > 0:
            cancel_rate_pct = (cancelled_orders / total_orders) * 100
            return_rate_pct = (returned_orders / total_orders) * 100
            risk_score = (cancel_rate_pct * 0.6) + (return_rate_pct * 0.4)
        else:
            risk_score = 0.0

        # Clamp risk score between 0 and 100
        risk_score = max(0.0, min(100.0, risk_score))

        # Call repository to update risk level and scores
        return await self.repository.update_risk_level_scores(
            customer_id=customer_id,
            platform=platform_enum,
            total_orders=total_orders,
            cancelled_orders=cancelled_orders,
            returned_orders=returned_orders,
            risk_score=risk_score
        )
