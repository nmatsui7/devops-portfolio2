# Intermediate DevOps Portfolio Tutorial — Volume 2

This repository is the sequel to the [Beginner DevOps Operations Tutorial](https://github.com/example/devops-portfolio). It builds on the same containerized app foundation but replaces the static Nginx site with a real Python API, introduces Helm packaging, GitOps with ArgoCD, advanced CI/CD with security scanning, and a complete observability stack including logs and distributed tracing.

**You should complete Volume 1 or already know Docker, Docker Compose, basic Kubernetes, Terraform, GitHub Actions, Prometheus/Grafana, and Ansible before starting here.**

## What Makes It A Sequel

| Volume 1 | Volume 2 |
|---|---|
| Static Nginx site | Python Flask API with PostgreSQL |
| Plain Kubernetes manifests | Helm charts with staging/production overlays |
| Basic CI/CD (lint, build, deploy) | CI/CD with integration tests, Trivy scan, DB migrations |
| Manual kubectl apply | GitOps with ArgoCD |
| Prometheus + Grafana only | Prometheus + Grafana + Loki (logs) + Tempo (traces) |
| Basic alert rules | Alertmanager with Slack routing |
| No app-level metrics | Custom Prometheus metrics (latency, errors, requests) |
| No security policies | Network policies, pod security contexts, OPA/Kyverno (optional) |
| Manual validation | Synthetic monitoring with K6 + Grafana dashboards |

## Project Layout

```
app/               Your workspace — stub files with TODO markers
solutions/app/     Complete reference implementation
docker/            Docker Compose files (exercise + solution modes)
```

## Exercise Workflow

This is a **write-code tutorial**. The Python files in `app/` start as stubs with `# TODO` markers. You fill in the implementation, then verify with tests.

```bash
# 1. Create and activate a virtual environment
python3 -m venv .venv
source .venv/bin/activate    # Windows: .venv\Scripts\activate

# 2. Write your code in app/
# 3. Run tests locally
pip install -r app/requirements.txt
pytest app/tests/ --cov=app --cov-report=term -v

# 4. Start the stack with your code
docker compose -f docker/docker-compose.yml up --build

# 5. Stuck? Spot typos with the diff tool
python scripts/diff_check.py

# 6. Stuck? Reveal the solutions
bash scripts/reveal_solutions.sh

# 7. Reset stubs to try again
bash scripts/reset_exercises.sh
```

## Quick Start (Solution Mode)

```bash
# Start the full local stack with the reference implementation
docker compose -f docker/docker-compose.yml -f docker/docker-compose.solution.yml up --build

# Check the API
curl http://localhost:8000/health
curl http://localhost:8000/ready
curl http://localhost:8000/metrics
curl http://localhost:8000/api/todos
```

## Local Services

| Service | URL | Notes |
|---|---|---|
| Flask API | http://localhost:8000 | Python API with PostgreSQL |
| API Docs | http://localhost:8000/docs | Swagger UI |
| Postgres | localhost:5432 | App database |
| Prometheus | http://localhost:9090 | Scrapes app + Loki |
| Grafana | http://localhost:3000 | Login: `admin` / `admin` |
| Loki | http://localhost:3100 | Log aggregation |
| Tempo | http://localhost:3200 | Distributed tracing |
| Jaeger UI | http://localhost:16686 | Trace visualization |
| Alertmanager | http://localhost:9093 | Alert routing |

## Learning Path

1. Write the Flask API code in `app/` — start with `models.py`, then `app.py`, then `migrations.py`.
2. Run `pytest app/tests/` to verify your implementation passes all tests.
3. Run the local stack (exercise or solution mode) and explore the API endpoints.
4. Read `helm/portfolio-app/` — compare it with the plain K8s manifests from Volume 1.
5. Inspect `argocd/` to understand GitOps application definitions.
6. Review the CI workflow — note the integration test and Trivy stages.
7. Open Grafana and explore the pre-loaded dashboards (logs, traces, app metrics).
8. Browse the Terraform scaffold and compare its additions (EKS add-ons, IRSA, etc.).

## Stack

| Layer | Tool |
|---|---|
| App | Flask + SQLAlchemy + PostgreSQL |
| IaC | Terraform |
| Containers | Docker, Docker Compose |
| Orchestration | Kubernetes + Helm |
| GitOps | ArgoCD |
| CI/CD | GitHub Actions |
| Metrics | Prometheus + custom app metrics |
| Logs | Loki + Promtail |
| Traces | OpenTelemetry + Tempo |
| Alerting | Alertmanager |
| Security | Trivy, Network Policies, Pod Security Contexts |
| Testing | Pytest, K6 |
| API docs | Swagger / OpenAPI |
