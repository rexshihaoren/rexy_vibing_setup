#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 <target-repo-path> [--ide trae|cursor|both] [--policy if-missing|never]"
  echo ""
  echo "Options:"
  echo "  --ide trae|cursor|both   Which adapters to generate (default: both)"
  echo "  --policy MODE            Policy copy mode (default: if-missing)"
  echo "  --with-trae              Alias for --ide trae"
  echo "  --with-cursor            Alias for --ide cursor"
}

require_cmd() {
  local cmd="$1"
  if ! command -v "${cmd}" >/dev/null 2>&1; then
    echo "Missing required command: ${cmd}" >&2
    exit 1
  fi
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CANON_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
POLICY_FILES=(AGENTS.md AGENT.md CLAUDE.md CURSOR.md .cursorrules)

TARGET_PATH=""
IDE="both"
IDE_SET=false
POLICY_MODE="if-missing"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ide)
      IDE="${2:-}"
      IDE_SET=true
      if [[ -z "${IDE}" ]]; then
        echo "--ide requires a value" >&2
        exit 1
      fi
      shift 2
      ;;
    --policy)
      POLICY_MODE="${2:-}"
      if [[ -z "${POLICY_MODE}" ]]; then
        echo "--policy requires a value" >&2
        exit 1
      fi
      shift 2
      ;;
    --with-trae)
      if [[ "${IDE_SET}" == "true" ]]; then
        echo "--with-trae cannot be combined with --ide" >&2
        exit 1
      fi
      IDE="trae"
      shift
      ;;
    --with-cursor)
      if [[ "${IDE_SET}" == "true" ]]; then
        echo "--with-cursor cannot be combined with --ide" >&2
        exit 1
      fi
      IDE="cursor"
      shift
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
      shift
      ;;
  esac
done

if [[ -z "${TARGET_PATH}" ]]; then
  usage >&2
  exit 1
fi

require_cmd bash
require_cmd cp
require_cmd rsync

TARGET_ROOT="$(cd "${TARGET_PATH}" 2>/dev/null && pwd || true)"
if [[ -z "${TARGET_ROOT}" ]]; then
  mkdir -p "${TARGET_PATH}"
  TARGET_ROOT="$(cd "${TARGET_PATH}" && pwd)"
fi

find_existing_policy_file() {
  local file_name
  for file_name in "${POLICY_FILES[@]}"; do
    if [[ -e "${TARGET_ROOT}/${file_name}" ]]; then
      echo "${file_name}"
      return 0
    fi
  done
  return 1
}

copy_policy_files_if_missing() {
  local existing_file

  case "${POLICY_MODE}" in
    if-missing)
      ;;
    never)
      echo "Policy copy disabled (--policy never)."
      return 0
      ;;
    *)
      echo "Invalid --policy value: ${POLICY_MODE} (expected if-missing|never)" >&2
      exit 1
      ;;
  esac

  if existing_file="$(find_existing_policy_file)"; then
    echo "Existing policy file found (${existing_file}); skipped AGENTS/shims."
    return 0
  fi

  echo "No policy files found; copying AGENTS/shims."
  local file_name
  for file_name in "${POLICY_FILES[@]}"; do
    if [[ -e "${TARGET_ROOT}/${file_name}" ]]; then
      echo "Refusing to overwrite unexpectedly created file: ${TARGET_ROOT}/${file_name}" >&2
      exit 1
    fi
    cp "${CANON_ROOT}/${file_name}" "${TARGET_ROOT}/${file_name}"
  done
}

sync_trae_adapter() {
  if [[ -d "${TARGET_ROOT}/.trae/skills" ]]; then
    echo "Refreshing Trae adapter."
  else
    echo "Creating Trae adapter."
  fi
  "${CANON_ROOT}/scripts/generate_trae_adapter.sh" --target "${TARGET_ROOT}"
}

sync_cursor_adapter() {
  if [[ -d "${TARGET_ROOT}/.cursor/skills" ]]; then
    echo "Refreshing Cursor adapter."
  else
    echo "Creating Cursor adapter."
  fi
  "${CANON_ROOT}/scripts/generate_cursor_adapter.sh" --target "${TARGET_ROOT}"
}

copy_policy_files_if_missing

case "${IDE}" in
  trae)
    sync_trae_adapter
    ;;
  cursor)
    sync_cursor_adapter
    ;;
  both)
    sync_trae_adapter
    sync_cursor_adapter
    ;;
  *)
    echo "Invalid --ide value: ${IDE} (expected trae|cursor|both)" >&2
    exit 1
    ;;
esac

echo "Attach complete."
echo "Target: ${TARGET_ROOT}"
echo "Generated: ${IDE}"
