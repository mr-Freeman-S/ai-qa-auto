#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p .runtime
install_dmg() {
  local url="$1" app="$2" disk="$PWD/.runtime/download.dmg" mount
  mount="$(mktemp -d /tmp/mm-qa-dmg.XXXXXX)"
  curl --fail --location --retry 3 "$url" -o "$disk"
  hdiutil attach "$disk" -nobrowse -mountpoint "$mount"
  if ! ditto "$mount/$app" "/Applications/$app"; then
    hdiutil detach "$mount"
    echo "Не удалось установить $app в /Applications. Установите приложение вручную и повторите запуск."
    exit 1
  fi
  hdiutil detach "$mount"
  rmdir "$mount"
  rm "$disk"
}
if [ ! -d '/Applications/Google Chrome.app' ]; then
  install_dmg 'https://dl.google.com/chrome/mac/universal/stable/GGRO/googlechrome.dmg' 'Google Chrome.app'
fi
if ! command -v ollama >/dev/null && [ ! -d /Applications/Ollama.app ]; then
  install_dmg 'https://ollama.com/download/Ollama.dmg' 'Ollama.app'
fi
if ! command -v claude >/dev/null; then
  curl --fail --location --retry 3 https://claude.ai/install.sh -o .runtime/install-claude.sh
  bash .runtime/install-claude.sh
fi
if ! curl --fail --silent --max-time 3 http://localhost:11434/api/version >/dev/null; then
  if [ -d /Applications/Ollama.app ]; then
    open /Applications/Ollama.app
  else
    nohup ollama serve > .runtime/ollama.log 2>&1 &
  fi
fi
