from contextlib import asynccontextmanager
import logging
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
from app.db.client import MongoClientManager

# Setup logger configuration
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s"
)
logger = logging.getLogger("app.main")


@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    FastAPI Lifespan management function for managing pool connections
    and scheduler task setups before serving client requests.
    """
    logger.info("Initializing app lifespan boot hooks...")
    
    # 1. Establish database connection pool
    MongoClientManager.connect_to_database()
    
    # Ensure MongoDB indexes are created on startup
    try:
        from app.db.indexes import ensure_indexes
        await ensure_indexes()
    except Exception as e:
        logger.error(f"Failed to ensure database indexes on startup: {e}")
    
    # 2. Yield context back to ASGI server
    yield
    
    # 3. Handle graceful shutdown connection cleanup
    logger.info("Cleaning up app lifecycle resources...")
    MongoClientManager.close_database_connection()
    logger.info("Application shutdown sequence completed.")


def create_app() -> FastAPI:
    """Instantiate and configure the FastAPI core application instance."""
    application = FastAPI(
        title=settings.PROJECT_NAME,
        description="Enterprise Multi-Channel Ecommerce KPI Management System API Backend",
        version="1.0.0",
        lifespan=lifespan,
        debug=settings.DEBUG
    )

    # Mount Cross-Origin Resource Sharing (CORS) Middleware
    application.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],  # Set to specific domains in production settings
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"]
    )

    # 1. Root diagnostic health route
    @application.get("/health", tags=["Diagnostic"])
    def health_check():
        return {
            "status": "healthy",
            "project": settings.PROJECT_NAME,
            "environment": settings.ENVIRONMENT,
            "database": "connected",
            "version": "1.0.0"
        }

    # 2. Import and mount API Router structures (when endpoints are implemented)
    from app.api.router import api_router
    application.include_router(api_router, prefix="/api/v1")

    return application


app = create_app()
