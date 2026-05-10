#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 <target-repo-path> [--with-trae]"
}

require_cmd() {
  local cmd="$1"
  if ! command -v "${cmd}" >/dev/null 2>&1; then
    echo "Missing required command: ${cmd}" >&2
    exit 1
  fi
}

WITH_TRAE=false
TARGET_PATH=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --with-trae)
      WITH_TRAE=true
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --*)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
    *)
      if [[ -n "${TARGET_PATH}" ]]; then
        echo "Only one target repo path is allowed." >&2
        usage >&2
        exit 1
      fi
      TARGET_PATH="$1"
      ;;
  esac
  shift
done

if [[ -z "${TARGET_PATH}" ]]; then
  usage >&2
  exit 1
fi

require_cmd bash
require_cmd cp
require_cmd rsync

SOURCE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mkdir -p "${TARGET_PATH}"
TARGET_ROOT="$(cd "${TARGET_PATH}" && pwd)"

if [[ "${TARGET_ROOT}" == "/" ]]; then
  echo "Refusing to bootstrap into filesystem root (/)." >&2
  exit 1
fi

if [[ ! -w "${TARGET_ROOT}" ]]; then
  echo "Target path is not writable: ${TARGET_ROOT}" >&2
  exit 1
fi

copy_file() {
  local src="$1"
  local dst="$2"
  mkdir -p "$(dirname "${dst}")"
  cp "${src}" "${dst}"
}

for file_name in AGENT.md AGENTS.md CLAUDE.md CURSOR.md .cursorrules; do
  copy_file "${SOURCE_ROOT}/${file_name}" "${TARGET_ROOT}/${file_name}"
done

mkdir -p "${TARGET_ROOT}/docs/ai"
rsync -a --delete "${SOURCE_ROOT}/docs/ai/skills/" "${TARGET_ROOT}/docs/ai/skills/"

mkdir -p "${TARGET_ROOT}/scripts"
copy_file "${SOURCE_ROOT}/scripts/generate_trae_adapter.sh" "${TARGET_ROOT}/scripts/generate_trae_adapter.sh"
chmod +x "${TARGET_ROOT}/scripts/generate_trae_adapter.sh"

if [[ "${WITH_TRAE}" == "true" ]]; then
  mkdir -p "${TARGET_ROOT}/.trae/skills"
  (cd "${TARGET_ROOT}" && ./scripts/generate_trae_adapter.sh)
fi

echo "Bootstrap complete."
echo "Target: ${TARGET_ROOT}"
echo "Copied: AGENT files + docs/ai/skills + scripts/generate_trae_adapter.sh"
if [[ "${WITH_TRAE}" == "true" ]]; then
  echo "Trae adapter generated at .trae/skills"
fi
