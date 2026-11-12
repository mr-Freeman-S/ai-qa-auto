#!/bin/bash
# Source this script to add the project-local Node to PATH if needed.
if ! command -v node >/dev/null || ! node -e 'process.exit(Number(process.versions.node.split(".")[0]) >= 22 ? 0 : 1)'; then
  mkdir -p .runtime/node
  if [ ! -x .runtime/node/bin/node ]; then
    case "$(uname -m)" in arm64) qa_arch=arm64;; x86_64) qa_arch=x64;; *) echo 'Неподдерживаемая архитектура'; exit 1;; esac
    curl -fsSL --retry 3 https://nodejs.org/dist/latest-v22.x/SHASUMS256.txt -o .runtime/SHASUMS256.txt
    qa_archive="$(awk -v arch="$qa_arch" '$2 ~ "darwin-" arch "[.]tar[.]gz$" {print $2}' .runtime/SHASUMS256.txt)"
    test -n "$qa_archive"
    curl -fL --retry 3 "https://nodejs.org/dist/latest-v22.x/$qa_archive" -o ".runtime/$qa_archive"
    (cd .runtime; awk -v file="$qa_archive" '$2 == file' SHASUMS256.txt | shasum -a 256 -c -)
    tar -xzf ".runtime/$qa_archive" -C .runtime/node --strip-components=1
    rm ".runtime/$qa_archive"
  fi
  export PATH="$PWD/.runtime/node/bin:$PATH"
fi
