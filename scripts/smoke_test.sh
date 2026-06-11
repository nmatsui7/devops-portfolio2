#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${1:-http://localhost:8000}"
FAILED=0

echo "=== Smoke Tests ==="

check() {
    local desc="$1"
    local url="$2"
    local expected="$3"
    echo -n "  $desc ... "
    if curl -sf "$url" | grep -q "$expected"; then
        echo "PASS"
    else
        echo "FAIL"
        FAILED=1
    fi
}

check "Health"   "$BASE_URL/health"   "healthy"
check "Ready"    "$BASE_URL/ready"    "ready"
check "Metrics"  "$BASE_URL/metrics"  "app_requests_total"
check "API Root" "$BASE_URL/"         "Portfolio API"
check "List Todos (empty)" "$BASE_URL/api/todos" "\\["

echo "=== Create Todo ==="
TODO_ID=$(curl -sf -X POST "$BASE_URL/api/todos" \
    -H "Content-Type: application/json" \
    -d '{"title":"smoke test"}' | python3 -c "import sys,json; print(json.load(sys.stdin)['id'])")
echo "  Created todo id=$TODO_ID"

check "Get Todo" "$BASE_URL/api/todos/$TODO_ID" "smoke test"

echo "=== Delete Todo ==="
curl -sf -X DELETE "$BASE_URL/api/todos/$TODO_ID" > /dev/null
echo "  Deleted todo id=$TODO_ID"

if [ "$FAILED" -eq 1 ]; then
    echo "SOME TESTS FAILED"
    exit 1
fi
echo "ALL TESTS PASSED"
