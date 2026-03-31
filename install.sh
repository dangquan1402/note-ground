#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUNDLE_DIR="${SCRIPT_DIR}/bundle"

if [[ $# -lt 1 ]]; then
  echo "Usage: ./install.sh /path/to/vault"
  exit 1
fi

VAULT_PATH="$1"
PLUGIN_DIR="${VAULT_PATH}/.obsidian/plugins/note-ground"

if [[ ! -d "${VAULT_PATH}" ]]; then
  echo "Vault not found: ${VAULT_PATH}"
  exit 1
fi

mkdir -p "${PLUGIN_DIR}"
cp "${BUNDLE_DIR}/main.js" "${PLUGIN_DIR}/main.js"
cp "${BUNDLE_DIR}/manifest.json" "${PLUGIN_DIR}/manifest.json"
cp "${BUNDLE_DIR}/styles.css" "${PLUGIN_DIR}/styles.css"

echo "Installed NoteGround into: ${PLUGIN_DIR}"
