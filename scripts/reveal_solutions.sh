#!/usr/bin/env bash
# Copy solution files into app/ so you can see the completed code.
# Use this after attempting the exercises yourself.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "Copying solutions to app/ ..."
cp "$PROJECT_DIR/solutions/app/app.py" "$PROJECT_DIR/app/app.py"
cp "$PROJECT_DIR/solutions/app/models.py" "$PROJECT_DIR/app/models.py"
cp "$PROJECT_DIR/solutions/app/config.py" "$PROJECT_DIR/app/config.py"
cp "$PROJECT_DIR/solutions/app/migrations.py" "$PROJECT_DIR/app/migrations.py"
cp "$PROJECT_DIR/solutions/app/tests/conftest.py" "$PROJECT_DIR/app/tests/conftest.py"
cp "$PROJECT_DIR/solutions/app/tests/test_api.py" "$PROJECT_DIR/app/tests/test_api.py"

echo "Done. The app/ directory now has the complete implementations."
echo ""
echo "Run tests to verify:"
echo "  pip install -r app/requirements.txt && pytest app/tests/"
