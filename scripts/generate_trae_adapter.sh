#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 [--target <repo-path>]"
  echo ""
  echo "Default behavior (no --target): generate adapter into this repo:"
  echo "  ./.trae/skills"
  echo ""
  echo "With --target: generate adapter into target repo:"
  echo "  <target>/.trae/skills"
}

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_DIR="${ROOT_DIR}/docs/ai/skills"
TARGET_ROOT="${ROOT_DIR}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      TARGET_ROOT="${2:-}"
      if [[ -z "${TARGET_ROOT}" ]]; then
        echo "--target requires a value" >&2
        exit 1
      fi
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ ! -d "${TARGET_ROOT}" ]]; then
  mkdir -p "${TARGET_ROOT}"
fi
TARGET_ROOT="$(cd "${TARGET_ROOT}" && pwd)"
TRAE_TARGET_DIR="${TARGET_ROOT}/.trae/skills"

if [[ ! -d "${SOURCE_DIR}" ]]; then
  echo "Source directory not found: ${SOURCE_DIR}" >&2
  exit 1
fi

mkdir -p "${TRAE_TARGET_DIR}"

# Keep target in sync with canonical source, but do not duplicate canonical README.
rsync -a --delete --exclude "README.md" "${SOURCE_DIR}/" "${TRAE_TARGET_DIR}/"

cat > "${TRAE_TARGET_DIR}/README.md" <<'EOF'
# Trae Skills Adapter (Generated)

This directory is a generated runtime adapter for Trae.
Do not edit files here manually.

Canonical source of truth:

- docs/ai/skills/

To refresh this adapter, run:

- <path-to-rexy_vibing_setup>/scripts/generate_trae_adapter.sh --target <repo>
EOF

echo "Synced skills:"
echo "  source: ${SOURCE_DIR}"
echo "  target: ${TRAE_TARGET_DIR}"
