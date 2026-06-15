# Intermediate DevOps Portfolio Tutorial — Volume 2

This repository is the sequel to the [Beginner DevOps Operations Tutorial](https://github.com/nmatsui7/devops-portfolio). It builds on the same containerized app foundation but replaces the static Nginx site with a real Python API, introduces Helm packaging, GitOps with ArgoCD, advanced CI/CD with security scanning, and a complete observability stack including logs and distributed tracing.

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

## Volume 2 Setup Options

You always need host tools for Docker, Git, and a Kubernetes cluster option such
as Minikube, Kind, Docker Desktop Kubernetes, or a remote cluster. On Windows,
use WSL2 if you want the Linux-style workflow shown in the tutorial.

For most learners, use the toolbox container. It avoids OS-specific CLI
installation issues while keeping Docker and Kubernetes on the host.

### Option A: Toolbox Container

Correct startup order:

1. Start Docker Desktop or Docker Engine on the host.
2. Pick one Kubernetes option and start it on the host: Minikube, Kind, Docker
   Desktop Kubernetes, or a remote cluster kubeconfig.
3. Confirm the host can reach the cluster:

```bash
kubectl get nodes
```

4. Build and start the toolbox:

```bash
docker build -t devops-toolbox:volume2 -f docker/devops-toolbox.Dockerfile .
./scripts/toolbox.sh
```

5. Inside the toolbox, confirm it can reach the same cluster:

```bash
kubectl get nodes
```

The toolbox includes common DevOps CLIs such as `kubectl`, `helm`, `argocd`,
`trivy`, `k6`, `jq`, `yq`, `yamllint`, `shellcheck`, `ansible`, and
`ansible-lint`. It does not run Kubernetes by itself; start Docker Desktop,
Minikube, Kind, or your real cluster on the host first.

By default, `scripts/toolbox.sh` mounts this repo into `/workspace` and mounts
`$HOME/.kube` read-only when available. If `$HOME/.minikube` exists, it also
mounts that directory read-only at the same absolute path because Minikube
kubeconfig often references cert/key files there. Docker socket access is
intentionally off by default. Use `./scripts/toolbox.sh --with-docker-socket`
only if you understand that mounting `/var/run/docker.sock` lets the container
control the host Docker daemon.

You usually write and edit the solution from outside the toolbox using your
normal editor, then verify and run commands inside the toolbox. This works
because `scripts/toolbox.sh` mounts your project directory into the toolbox at
`/workspace`.

When you are done inside the toolbox, run `exit` or press `Ctrl+D`. Because the
helper script uses `--rm`, the container should be removed automatically after
you exit. To check for leftover toolbox containers:

```bash
docker ps -a --filter "ancestor=devops-toolbox:volume2"
```

You do not need to rebuild the toolbox every day. Rebuild only when
`docker/devops-toolbox.Dockerfile` changes or when pinned tool versions are
updated. Otherwise, run `./scripts/toolbox.sh` again.

### Option B: Native Installation

Only use this path if you do not want to use the toolbox container. These native
install commands are redundant when you use Option A.

On macOS with Homebrew:

```bash
brew install helm argocd trivy k6 python curl
```

On Ubuntu or Debian:

```bash
sudo apt update && sudo apt install -y curl python3 python3-pip gnupg apt-transport-https
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd /usr/local/bin/argocd && rm argocd
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sudo sh -s -- -b /usr/local/bin
curl -fsSL https://dl.k6.io/key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/k6-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/k6-archive-keyring.gpg] https://dl.k6.io/deb stable main" | sudo tee /etc/apt/sources.list.d/k6.list
sudo apt update && sudo apt install -y k6
```

On Windows, the recommended path is Docker Desktop with WSL2 enabled, then
Option A from WSL or Git Bash. If you prefer native PowerShell tools, install
the Volume 2 CLIs with `winget`:

```powershell
winget install --id Helm.Helm -e
winget install --id Python.Python.3.12 -e
winget install --id Argo.argocd -e
winget install --id AquaSecurity.Trivy -e
winget install --id GrafanaLabs.k6 -e
```

From WSL or Git Bash on Windows, the toolbox flow is still:

```bash
docker build -t devops-toolbox:volume2 -f docker/devops-toolbox.Dockerfile .
./scripts/toolbox.sh
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

## Ansible Prerequisite

Volume 1 includes a local Ansible SSH lab where one playbook configures three
Docker-based Ubuntu targets as nginx web servers. Volume 2 assumes you already
understand inventory files, SSH targets, facts, templates, and basic playbook
execution.

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
