#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=""
if [[ -n "${BASH_SOURCE[0]:-}" && -e "${BASH_SOURCE[0]}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi
BUNDLE_DIR="${SCRIPT_DIR:+${SCRIPT_DIR}/bundle}"
RAW_BASE_URL="${NOTE_GROUND_RAW_BASE_URL:-https://raw.githubusercontent.com/dangquan1402/note-ground/main/bundle}"

usage() {
  cat <<'EOF'
Usage:
  ./install.sh /path/to/vault
  ./install.sh --active-vault

Options:
  --active-vault   Detect the currently open Obsidian vault from app config
EOF
}

download_bundle_file() {
  local file_name="$1"
  local target_path="$2"
  curl -fsSL "${RAW_BASE_URL}/${file_name}" -o "${target_path}"
}

install_bundle_file() {
  local file_name="$1"
  local target_path="$2"

  if [[ -n "${BUNDLE_DIR}" && -f "${BUNDLE_DIR}/${file_name}" ]]; then
    cp "${BUNDLE_DIR}/${file_name}" "${target_path}"
    return 0
  fi

  download_bundle_file "${file_name}" "${target_path}"
}

detect_obsidian_config() {
  case "$(uname -s)" in
    Darwin)
      echo "${HOME}/Library/Application Support/obsidian/obsidian.json"
      ;;
    Linux)
      echo "${HOME}/.config/obsidian/obsidian.json"
      ;;
    MINGW*|MSYS*|CYGWIN*)
      if [[ -n "${APPDATA:-}" ]]; then
        echo "${APPDATA}/obsidian/obsidian.json"
      else
        echo "${HOME}/AppData/Roaming/obsidian/obsidian.json"
      fi
      ;;
    *)
      return 1
      ;;
  esac
}

detect_active_vault() {
  local config_path
  config_path="$(detect_obsidian_config)" || return 1

  if [[ ! -f "${config_path}" ]]; then
    echo "Obsidian config not found: ${config_path}" >&2
    return 1
  fi

  node - "${config_path}" <<'EOF'
const fs = require("node:fs");
const configPath = process.argv[2];
const raw = fs.readFileSync(configPath, "utf8");
const parsed = JSON.parse(raw);
const vaults = parsed.vaults && typeof parsed.vaults === "object" ? Object.values(parsed.vaults) : [];
const active = vaults
  .filter((entry) => entry && typeof entry.path === "string")
  .sort((a, b) => Number(b.open === true) - Number(a.open === true) || Number(b.ts ?? 0) - Number(a.ts ?? 0))[0];

if (!active || typeof active.path !== "string") {
  process.exit(1);
}

process.stdout.write(active.path);
EOF
}

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

VAULT_PATH=""

case "${1}" in
  --active-vault)
    VAULT_PATH="$(detect_active_vault)" || {
      echo "Could not detect the active Obsidian vault." >&2
      exit 1
    }
    ;;
  -h|--help)
    usage
    exit 0
    ;;
  *)
    VAULT_PATH="$1"
    ;;
esac

PLUGIN_DIR="${VAULT_PATH}/.obsidian/plugins/note-ground"

if [[ ! -d "${VAULT_PATH}" ]]; then
  echo "Vault not found: ${VAULT_PATH}"
  exit 1
fi

mkdir -p "${PLUGIN_DIR}"
install_bundle_file "main.js" "${PLUGIN_DIR}/main.js"
install_bundle_file "manifest.json" "${PLUGIN_DIR}/manifest.json"
install_bundle_file "styles.css" "${PLUGIN_DIR}/styles.css"

echo "Installed NoteGround into: ${PLUGIN_DIR}"
