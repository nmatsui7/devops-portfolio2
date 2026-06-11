import pytest
import sqlalchemy as sa
from app import app as flask_app
from models import db as _db

@pytest.fixture
def app():
    flask_app.config["TESTING"] = True
    flask_app.config["SQLALCHEMY_DATABASE_URI"] = "sqlite:///:memory:"
    with flask_app.app_context():
        # Replace the cached PostgreSQL engine with a SQLite one for testing
        engine = sa.create_engine("sqlite:///:memory:")
        flask_app.extensions["sqlalchemy"]._app_engines[flask_app][None] = engine
        _db.create_all()
        yield flask_app
        _db.drop_all()

@pytest.fixture
def client(app):
    return app.test_client()
