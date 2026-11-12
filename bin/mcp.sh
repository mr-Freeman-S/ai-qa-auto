#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
source bin/node.sh
secret_args=()
if [ -f .env ]; then
  secret_args=(--secrets "$PWD/.env")
fi
exec node node_modules/@playwright/mcp/cli.js \
  "${secret_args[@]}" \
  --executable-path "${QA_CHROME_PATH:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}" \
  --isolated \
  --output-dir "${QA_REPORT_DIR:-$PWD/reports/manual}"
