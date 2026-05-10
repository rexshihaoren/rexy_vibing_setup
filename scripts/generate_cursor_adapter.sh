#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_DIR="${ROOT_DIR}/docs/ai/skills"
CURSOR_TARGET_DIR="${ROOT_DIR}/.cursor/skills"

if [[ ! -d "${SOURCE_DIR}" ]]; then
  echo "Source directory not found: ${SOURCE_DIR}" >&2
  exit 1
fi

mkdir -p "${CURSOR_TARGET_DIR}"

# Keep target in sync with canonical source, but do not duplicate canonical README.
rsync -a --delete --exclude "README.md" "${SOURCE_DIR}/" "${CURSOR_TARGET_DIR}/"

cat > "${CURSOR_TARGET_DIR}/README.md" <<'EOF'
# Cursor Skills Adapter (Generated)

This directory is a generated runtime adapter for Cursor.
Do not edit files here manually.

Canonical source of truth:

- docs/ai/skills/

To refresh this adapter, run:

- ./scripts/generate_cursor_adapter.sh
EOF

echo "Synced skills:"
echo "  source: ${SOURCE_DIR}"
echo "  target: ${CURSOR_TARGET_DIR}"
