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
            
            from decimal import Decimal
            from bson.codec_options import TypeCodec, TypeRegistry, CodecOptions
            from bson.decimal128 import Decimal128

            class DecimalCodec(TypeCodec):
                python_type = Decimal
                bson_type = Decimal128

                def transform_python(self, value):
                    return Decimal128(value)

                def transform_bson(self, value):
                    return value.to_decimal()

            codec_options = CodecOptions(type_registry=TypeRegistry([DecimalCodec()]))
            cls.db = cls.client.get_database(settings.DATABASE_NAME, codec_options=codec_options)
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
