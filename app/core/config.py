from typing import List
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=True,
        extra="ignore"
    )

    # Core
    PROJECT_NAME: str = "Enterprise Multi-Channel Ecommerce KPI Management System"
    APP_NAME: str = "ecommerce_kpi"
    ENVIRONMENT: str = "development"
    DEBUG: bool = True

    # MongoDB
    MONGODB_URL: str = "mongodb://localhost:27017"
    DATABASE_NAME: str = "ecommerce_kpi_system"

    # Security
    JWT_SECRET_KEY: str = "replace-this-with-a-secure-random-secret-key-for-jwt-in-production"
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60
    SESSION_EXPIRE_HOURS: int = 24

    # Email
    SMTP_HOST: str = "smtp.gmail.com"
    SMTP_PORT: int = 587
    SMTP_USER: str = ""
    SMTP_PASSWORD: str = ""
    SMTP_FROM_EMAIL: str = "noreply@ecommercekpi.com"

    # Scheduler
    ENABLE_JOBS: bool = True


settings = Settings()
