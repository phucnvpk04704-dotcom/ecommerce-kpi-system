from datetime import datetime, timezone
from typing import Optional
from pymongo import ReturnDocument
from motor.motor_asyncio import AsyncIOMotorCollection
from app.repositories.base import BaseRepository
from app.models.customer_blacklist import CustomerBlacklist
from app.schemas.customer_blacklist import CustomerBlacklistCreate, CustomerBlacklistUpdate
from app.core.enums.risk_level import RiskLevel
from app.core.enums.platform import Platform


class CustomerBlacklistRepository(BaseRepository[CustomerBlacklist, CustomerBlacklistCreate, CustomerBlacklistUpdate]):
    """
    Concrete Repository class for executing operations on the 'customer_blacklist' collection.
    """
    def __init__(self, collection: AsyncIOMotorCollection):
        super().__init__(collection, CustomerBlacklist)

    async def find_by_phone(self, customer_phone: str) -> Optional[CustomerBlacklist]:
        """Find a blacklist profile by customer phone number."""
        return await self.find_one({"customer_phone": customer_phone})

    async def update_risk_level_scores(
        self,
        customer_id: str,
        platform: Platform,
        total_orders: int,
        cancelled_orders: int,
        returned_orders: int,
        risk_score: float
    ) -> Optional[CustomerBlacklist]:
        """
        Compute risk classification and update metrics for a customer blacklist document.
        Returns:
            CustomerBlacklist | None
        """
        # Determine risk level based on score boundaries
        if risk_score < 30.0:
            calculated_level = RiskLevel.LOW
        elif risk_score < 60.0:
            calculated_level = RiskLevel.MEDIUM
        elif risk_score < 85.0:
            calculated_level = RiskLevel.HIGH
        else:
            calculated_level = RiskLevel.BLACKLIST

        update_data = {
            "total_orders": total_orders,
            "cancelled_orders": cancelled_orders,
            "returned_orders": returned_orders,
            "risk_score": risk_score,
            "risk_level": calculated_level,
            "updated_at": datetime.now(timezone.utc)
        }

        document = await self.collection.find_one_and_update(
            {"customer_id": customer_id, "platform": platform},
            {"$set": update_data},
            return_document=ReturnDocument.AFTER
        )
        
        if document:
            return self.model_class.model_validate(document)
        return None
