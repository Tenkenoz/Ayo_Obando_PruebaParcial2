from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    # Base de datos PostgreSQL
    DATABASE_URL: str = "postgresql://segurouser:seguro_pass@db:5432/segurodb"

    APP_NAME: str = "SeguroApp"
    DEBUG: bool = False

    class Config:
        env_file = ".env"
        extra = "ignore"


settings = Settings()