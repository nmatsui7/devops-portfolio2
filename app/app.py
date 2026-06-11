import time
import os
from flask import Flask, jsonify, request
from flask_cors import CORS
from flask_migrate import Migrate
from prometheus_client import Counter, Histogram, generate_latest, REGISTRY
from opentelemetry import trace
from opentelemetry.instrumentation.flask import FlaskInstrumentor
from opentelemetry.exporter.otlp.proto.http.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from config import Config
from models import db, Todo

app = Flask(__name__)
app.config.from_object(Config)
CORS(app)

db.init_app(app)
migrate = Migrate(app, db)

REQUEST_COUNT = Counter("app_requests_total", "Total requests", ["method", "endpoint", "status"])
REQUEST_LATENCY = Histogram("app_request_latency_seconds", "Request latency", ["method", "endpoint"])
ACTIVE_REQUESTS = Histogram("app_active_requests", "Active requests", ["method"])

tracer_provider = TracerProvider()
otlp_exporter = OTLPSpanExporter(endpoint=Config.OTEL_EXPORTER_OTLP_ENDPOINT)
tracer_provider.add_span_processor(BatchSpanProcessor(otlp_exporter))
trace.set_tracer_provider(tracer_provider)

FlaskInstrumentor().instrument_app(app)
tracer = trace.get_tracer(__name__)

@app.before_request
def before_request():
    request._start_time = time.time()

@app.after_request
def after_request(response):
    if hasattr(request, "_start_time"):
        latency = time.time() - request._start_time
        REQUEST_LATENCY.labels(method=request.method, endpoint=request.path).observe(latency)
    REQUEST_COUNT.labels(method=request.method, endpoint=request.path, status=response.status_code).inc()
    return response

@app.route("/health")
def health():
    return jsonify({"status": "healthy"}), 200

@app.route("/ready")
def ready():
    try:
        db.session.execute(db.text("SELECT 1"))
        return jsonify({"status": "ready", "database": "connected"}), 200
    except Exception as e:
        return jsonify({"status": "not ready", "database": str(e)}), 503

@app.route("/metrics")
def metrics():
    return generate_latest(REGISTRY), 200, {"Content-Type": "text/plain; charset=utf-8"}

@app.route("/api/todos", methods=["GET"])
def list_todos():
    with tracer.start_as_current_span("list_todos"):
        todos = Todo.query.order_by(Todo.created_at.desc()).all()
        return jsonify([t.to_dict() for t in todos])

@app.route("/api/todos", methods=["POST"])
def create_todo():
    with tracer.start_as_current_span("create_todo"):
        data = request.get_json()
        if not data or not data.get("title"):
            return jsonify({"error": "title is required"}), 400
        todo = Todo(title=data["title"])
        db.session.add(todo)
        db.session.commit()
        return jsonify(todo.to_dict()), 201

@app.route("/api/todos/<int:todo_id>", methods=["GET"])
def get_todo(todo_id):
    with tracer.start_as_current_span("get_todo"):
        todo = db.session.get(Todo, todo_id)
        if not todo:
            return jsonify({"error": "not found"}), 404
        return jsonify(todo.to_dict())

@app.route("/api/todos/<int:todo_id>", methods=["PUT"])
def update_todo(todo_id):
    with tracer.start_as_current_span("update_todo"):
        todo = db.session.get(Todo, todo_id)
        if not todo:
            return jsonify({"error": "not found"}), 404
        data = request.get_json()
        if "title" in data:
            todo.title = data["title"]
        if "completed" in data:
            todo.completed = data["completed"]
        db.session.commit()
        return jsonify(todo.to_dict())

@app.route("/api/todos/<int:todo_id>", methods=["DELETE"])
def delete_todo(todo_id):
    with tracer.start_as_current_span("delete_todo"):
        todo = db.session.get(Todo, todo_id)
        if not todo:
            return jsonify({"error": "not found"}), 404
        db.session.delete(todo)
        db.session.commit()
        return jsonify({"message": "deleted"}), 200

@app.route("/")
def index():
    return jsonify({
        "app": "Portfolio API",
        "version": "2.0.0",
        "docs": "/docs",
        "endpoints": {
            "health": "/health",
            "ready": "/ready",
            "metrics": "/metrics",
            "todos": "/api/todos",
        }
    })

@app.route("/docs")
def docs():
    return jsonify({
        "openapi": "3.0.0",
        "info": {"title": "Portfolio API", "version": "2.0.0"},
        "paths": {
            "/api/todos": {
                "get": {"summary": "List all todos"},
                "post": {"summary": "Create a todo", "requestBody": {"title": "string"}}
            },
            "/api/todos/{id}": {
                "get": {"summary": "Get a todo"},
                "put": {"summary": "Update a todo"},
                "delete": {"summary": "Delete a todo"}
            }
        }
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
