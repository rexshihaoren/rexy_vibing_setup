#!/usr/bin/env bash
# Refresh files previously installed by install.sh or bootstrap (with version record).
# Re-downloads upstream and re-runs bootstrap from the new tarball.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION_FILE="${ROOT}/.rexy-vibing-version"

usage() {
  echo "Usage: $0 [--ref REF] [--dry-run] [-y]"
  echo ""
  echo "  --ref REF     Upstream branch or tag to apply (default: main)"
  echo "  --dry-run     Show rsync itemize changes only; do not modify files"
  echo "  -y            Skip confirmation before applying (ignored with --dry-run)"
}

REPO=""
RECORDED_REF=""
NEW_REF="main"
DRY_RUN=false
ASSUME_YES=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ref)
      NEW_REF="${2:-}"
      if [[ -z "${NEW_REF}" ]]; then echo "--ref requires a value" >&2; exit 1; fi
      shift 2
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    -y)
      ASSUME_YES=true
      shift
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

if [[ ! -f "${VERSION_FILE}" ]]; then
  echo "Missing ${VERSION_FILE}" >&2
  echo "Install with scripts/install.sh, or run bootstrap with REXY_VIBING_RECORD_REF set." >&2
  exit 1
fi

while IFS= read -r line || [[ -n "${line}" ]]; do
  [[ -z "${line}" || "${line}" =~ ^# ]] && continue
  case "${line}" in
    REPO=*) REPO="${line#REPO=}" ;;
    REF=*) RECORDED_REF="${line#REF=}" ;;
  esac
done < "${VERSION_FILE}"

if [[ -z "${REPO}" ]]; then
  echo "${VERSION_FILE} must contain a REPO= line." >&2
  exit 1
fi

require_cmd() {
  local cmd="$1"
  if ! command -v "${cmd}" >/dev/null 2>&1; then
    echo "Missing required command: ${cmd}" >&2
    exit 1
  fi
}

require_cmd bash
require_cmd curl
require_cmd tar
require_cmd mktemp
require_cmd rsync

WITH_TRAE=false
WITH_CURSOR=false
[[ -d "${ROOT}/.trae/skills" ]] && WITH_TRAE=true
[[ -d "${ROOT}/.cursor/skills" ]] && WITH_CURSOR=true

TMP_DIR="$(mktemp -d)"
cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

ARCHIVE="${TMP_DIR}/upstream.tar.gz"
URL="https://github.com/${REPO}/archive/${NEW_REF}.tar.gz"

echo "Current record: ${REPO}@${RECORDED_REF:-unknown}"
echo "Update source:  ${URL}"

if ! curl -fsSL "${URL}" -o "${ARCHIVE}"; then
  echo "Failed to download archive." >&2
  exit 1
fi

tar xzf "${ARCHIVE}" -C "${TMP_DIR}"
TOP="$(tar tzf "${ARCHIVE}" | head -1 | cut -d/ -f1)"
SRC="${TMP_DIR}/${TOP}"

if [[ ! -f "${SRC}/scripts/bootstrap.sh" ]]; then
  echo "Archive layout unexpected (missing scripts/bootstrap.sh)." >&2
  exit 1
fi

if [[ "${DRY_RUN}" == "true" ]]; then
  echo ""
  echo "Dry-run: unified diffs for root policy files (if both sides exist):"
  for f in AGENTS.md AGENT.md CLAUDE.md CURSOR.md .cursorrules; do
    if [[ -f "${SRC}/${f}" && -f "${ROOT}/${f}" ]]; then
      diff -u "${ROOT}/${f}" "${SRC}/${f}" || true
    elif [[ -f "${SRC}/${f}" && ! -f "${ROOT}/${f}" ]]; then
      echo "--- new file: ${f}"
    fi
  done
  echo ""
  echo "Dry-run: scripts this bootstrap manages:"
  for s in bootstrap.sh generate_trae_adapter.sh generate_cursor_adapter.sh install.sh rexy-vibing-update.sh; do
    if [[ -f "${SRC}/scripts/${s}" && -f "${ROOT}/scripts/${s}" ]]; then
      diff -u "${ROOT}/scripts/${s}" "${SRC}/scripts/${s}" || true
    elif [[ -f "${SRC}/scripts/${s}" && ! -f "${ROOT}/scripts/${s}" ]]; then
      echo "--- new file: scripts/${s}"
    fi
  done
  echo ""
  echo "Dry-run: skills tree (rsync itemize, matches bootstrap --delete):"
  if [[ -d "${SRC}/docs/ai/skills" ]]; then
    mkdir -p "${ROOT}/docs/ai/skills"
    rsync -a --delete --dry-run -i "${SRC}/docs/ai/skills/" "${ROOT}/docs/ai/skills/" || true
  fi
  echo ""
  echo "Re-run without --dry-run to apply (runs bootstrap from ${NEW_REF})."
  exit 0
fi

if [[ "${ASSUME_YES}" != "true" ]]; then
  echo ""
  read -r -p "Apply update from ${REPO}@${NEW_REF} into ${ROOT}? [y/N] " reply
  case "${reply}" in
    y|Y|yes|YES) ;;
    *) echo "Aborted."; exit 1 ;;
  esac
fi

BOOT_ARGS=()
[[ "${WITH_TRAE}" == "true" ]] && BOOT_ARGS+=(--with-trae)
[[ "${WITH_CURSOR}" == "true" ]] && BOOT_ARGS+=(--with-cursor)

export REXY_VIBING_RECORD_REPO="${REPO}"
export REXY_VIBING_RECORD_REF="${NEW_REF}"

"${SRC}/scripts/bootstrap.sh" "${ROOT}" "${BOOT_ARGS[@]}"
echo "Update complete. Recorded ${REPO}@${NEW_REF} in ${VERSION_FILE}."
