import time
from flask import Flask, jsonify, request
from flask_cors import CORS
from flask_migrate import Migrate

# TODO: Import Prometheus client classes
# from prometheus_client import ...

# TODO: Import OpenTelemetry classes and FlaskInstrumentor
# from opentelemetry import ...
# from opentelemetry.instrumentation.flask import ...
# from opentelemetry.exporter.otlp.proto.http.trace_exporter import ...
# from opentelemetry.sdk.trace import ...
# from opentelemetry.sdk.trace.export import ...

from config import Config
from models import db, Todo

app = Flask(__name__)
app.config.from_object(Config)
CORS(app)

db.init_app(app)
migrate = Migrate(app, db)

# TODO: Create Prometheus metrics

# TODO: Set up OpenTelemetry

# TODO: Add before_request handler

# TODO: Add after_request handler

@app.route("/health")
def health():
    # TODO: Return {"status": "healthy"} with 200 status
    pass

@app.route("/ready")
def ready():
    # TODO: Execute SELECT 1 to verify DB connectivity
    pass

@app.route("/metrics")
def metrics():
    # TODO: Return Prometheus metrics
    pass

@app.route("/api/todos", methods=["GET"])
def list_todos():
    # TODO: Query all todos ordered by created_at descending
    pass

@app.route("/api/todos", methods=["POST"])
def create_todo():
    # TODO: Parse JSON, validate title, create and persist Todo
    pass

@app.route("/api/todos/<int:todo_id>", methods=["GET"])
def get_todo(todo_id):
    # TODO: Fetch todo by ID, return 404 if not found
    pass

@app.route("/api/todos/<int:todo_id>", methods=["PUT"])
def update_todo(todo_id):
    # TODO: Fetch todo, update title/completed from request body
    pass

@app.route("/api/todos/<int:todo_id>", methods=["DELETE"])
def delete_todo(todo_id):
    # TODO: Fetch todo, delete it
    pass

@app.route("/")
def index():
    # TODO: Return a JSON root with app name, version, and endpoint listing
    pass

@app.route("/docs")
def docs():
    # TODO: Return an OpenAPI-style JSON describing the API
    pass

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
