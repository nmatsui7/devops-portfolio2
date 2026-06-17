from flask_sqlalchemy import SQLAlchemy
from datetime import datetime, timezone

db = SQLAlchemy()

# TODO: Define the Todo model with these fields:
#   id        - Integer, primary key
#   title     - String(200), nullable=False
#   completed - Boolean, default=False
#   created_at - DateTime, defaults to utcnow
#   updated_at - DateTime, defaults to utcnow, updates on change
#
# Include a to_dict() method that returns a dict with all fields.
#
# class Todo(db.Model):
#     __tablename__ = "todos"
#     ...
