import logging
from motor.motor_asyncio import AsyncIOMotorClient
from app.core.config import settings

logger = logging.getLogger("app.db")


class MongoClientManager:
    client: AsyncIOMotorClient = None
    db = None

    @classmethod
    def connect_to_database(cls) -> None:
        """Initialize AsyncIOMotorClient and select database."""
        if cls.client is None:
            logger.info(f"Connecting to MongoDB at {settings.MONGODB_URL}...")
            cls.client = AsyncIOMotorClient(settings.MONGODB_URL)
            cls.db = cls.client[settings.DATABASE_NAME]
            logger.info("Successfully connected to MongoDB.")

    @classmethod
    def close_database_connection(cls) -> None:
        """Close connection pools on application shutdown."""
        if cls.client is not None:
            logger.info("Closing MongoDB connection pool...")
            cls.client.close()
            cls.client = None
            cls.db = None
            logger.info("MongoDB connection pool closed.")


def get_database():
    """Dependency helper or direct getter for the database instance."""
    if MongoClientManager.db is None:
        MongoClientManager.connect_to_database()
    return MongoClientManager.db
