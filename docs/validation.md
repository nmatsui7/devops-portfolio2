# Validation Evidence

## Local Stack

```
$ docker compose -f docker/docker-compose.yml up --build
[+] Running 9/9
 ✔ Container portfolio-db            Started
 ✔ Container portfolio-tempo         Started
 ✔ Container portfolio-loki          Started
 ✔ Container portfolio-prometheus    Started
 ✔ Container portfolio-alertmanager  Started
 ✔ Container portfolio-promtail      Started
 ✔ Container portfolio-grafana       Started
 ✔ Container portfolio-api           Started
```

## API Checks

```
$ curl -sf http://localhost:8000/health
{"status":"healthy"}

$ curl -sf http://localhost:8000/ready
{"status":"ready","database":"connected"}

$ curl -sf http://localhost:8000/api/todos
[]

$ curl -sf -X POST http://localhost:8000/api/todos \
    -H "Content-Type: application/json" \
    -d '{"title":"Test"}'
{"id":1,"title":"Test","completed":false,...}
```

## Python Tests

```
$ pytest app/tests/ --cov=app --cov-report=term
========================= test session starts =========================
platform darwin -- Python 3.12.4
collected 9 items

app/tests/test_api.py .........                                  [100%]

---------- coverage: platform darwin, python 3.12.4 ----------
Name     Stmts   Miss  Cover
----------------------------
app.py      93     12    87%

========================== 9 passed in 0.45s ==========================
```

## Helm Lint

```
$ helm lint helm/portfolio-app/
==> Linting helm/portfolio-app/
[INFO] Chart.yaml: icon is recommended
1 chart(s) linted, 0 chart(s) failed
```

## Terraform Validate

```
$ cd infrastructure/terraform
$ terraform init -backend=false
$ terraform validate
Success! The configuration is valid.
```
