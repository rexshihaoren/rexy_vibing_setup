#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_DIR="${ROOT_DIR}/docs/ai/skills"
TRAE_TARGET_DIR="${ROOT_DIR}/.trae/skills"

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

- ./scripts/generate_trae_adapter.sh
EOF

echo "Synced skills:"
echo "  source: ${SOURCE_DIR}"
echo "  target: ${TRAE_TARGET_DIR}"
