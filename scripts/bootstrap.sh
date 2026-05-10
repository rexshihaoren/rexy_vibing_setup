#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <target-repo-path> [--with-trae]" >&2
  exit 1
fi

SOURCE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_ROOT="$(cd "$1" && pwd)"
WITH_TRAE="${2:-}"

copy_file() {
  local src="$1"
  local dst="$2"
  mkdir -p "$(dirname "${dst}")"
  cp "${src}" "${dst}"
}

copy_file "${SOURCE_ROOT}/AGENT.md" "${TARGET_ROOT}/AGENT.md"
copy_file "${SOURCE_ROOT}/AGENTS.md" "${TARGET_ROOT}/AGENTS.md"
copy_file "${SOURCE_ROOT}/CLAUDE.md" "${TARGET_ROOT}/CLAUDE.md"
copy_file "${SOURCE_ROOT}/CURSOR.md" "${TARGET_ROOT}/CURSOR.md"
copy_file "${SOURCE_ROOT}/.cursorrules" "${TARGET_ROOT}/.cursorrules"

mkdir -p "${TARGET_ROOT}/docs/ai"
rsync -a --delete "${SOURCE_ROOT}/docs/ai/skills/" "${TARGET_ROOT}/docs/ai/skills/"

mkdir -p "${TARGET_ROOT}/scripts"
copy_file "${SOURCE_ROOT}/scripts/sync_skills.sh" "${TARGET_ROOT}/scripts/sync_skills.sh"
chmod +x "${TARGET_ROOT}/scripts/sync_skills.sh"

if [[ "${WITH_TRAE}" == "--with-trae" ]]; then
  mkdir -p "${TARGET_ROOT}/.trae/skills"
  (cd "${TARGET_ROOT}" && ./scripts/sync_skills.sh)
fi

echo "Bootstrap complete."
echo "Target: ${TARGET_ROOT}"
echo "Copied: AGENT files + docs/ai/skills + scripts/sync_skills.sh"
if [[ "${WITH_TRAE}" == "--with-trae" ]]; then
  echo "Trae adapter generated at .trae/skills"
fi
