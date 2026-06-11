import os

class Config:
    SQLALCHEMY_DATABASE_URI = os.getenv(
        "DATABASE_URL",
        "postgresql://portfolio:portfolio@localhost:5432/portfolio"
    )
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    OTEL_SERVICE_NAME = os.getenv("OTEL_SERVICE_NAME", "portfolio-app")
    OTEL_EXPORTER_OTLP_ENDPOINT = os.getenv("OTEL_EXPORTER_OTLP_ENDPOINT", "http://tempo:4318")
