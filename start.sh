#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
if [ "$(uname -s)" != Darwin ]; then
  echo 'Этот запуск настроен для macOS.'
  exit 1
fi
source bin/node.sh
node qa.mjs setup
if [ "$#" -eq 0 ]; then
  exec node qa.mjs run smoke --role sysadmin
fi
exec node qa.mjs run "$@"
