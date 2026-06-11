#!/usr/bin/env python3
"""Seed the database with sample todos."""
import sys
import requests

BASE_URL = sys.argv[1] if len(sys.argv) > 1 else "http://localhost:8000"

todos = [
    "Learn Docker basics",
    "Complete Volume 1 tutorial",
    "Deploy with Helm",
    "Set up ArgoCD",
    "Configure Loki logging",
    "Add distributed tracing",
    "Write integration tests",
    "Scan images with Trivy",
]

for title in todos:
    resp = requests.post(f"{BASE_URL}/api/todos", json={"title": title})
    if resp.status_code == 201:
        print(f"  Created: {title}")
    else:
        print(f"  Failed: {title} ({resp.status_code})")

print(f"Seeded {len(todos)} todos")
