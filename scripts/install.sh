#!/usr/bin/env bash
# Remote entrypoint: download a pinned GitHub ref of this repo, then bootstrap into a target repo.
# Example:
#   curl -fsSL "https://raw.githubusercontent.com/rexshihaoren/rexy_vibing_setup/main/scripts/install.sh" | bash -s -- /path/to/target-repo --with-cursor
set -euo pipefail

usage() {
  echo "Usage: curl -fsSL \"https://raw.githubusercontent.com/<owner>/<repo>/<ref>/scripts/install.sh\" | bash -s -- <target-repo-path> [options]"
  echo ""
  echo "Options (same as bootstrap):"
  echo "  --with-trae     Generate .trae/skills after copy"
  echo "  --with-cursor   Generate .cursor/skills after copy"
  echo ""
  echo "Install-only options:"
  echo "  --repo OWNER/NAME   GitHub repo to download (default: rexshihaoren/rexy_vibing_setup)"
  echo "  --ref REF             Branch or tag name (default: main)"
}

require_cmd() {
  local cmd="$1"
  if ! command -v "${cmd}" >/dev/null 2>&1; then
    echo "Missing required command: ${cmd}" >&2
    exit 1
  fi
}

REPO="${REXY_VIBING_REPO:-rexshihaoren/rexy_vibing_setup}"
REF="${REXY_VIBING_REF:-main}"
TARGET_PATH=""
BOOTSTRAP_ARGS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)
      REPO="${2:-}"
      if [[ -z "${REPO}" ]]; then echo "--repo requires a value" >&2; exit 1; fi
      shift 2
      ;;
    --ref)
      REF="${2:-}"
      if [[ -z "${REF}" ]]; then echo "--ref requires a value" >&2; exit 1; fi
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --with-trae|--with-cursor)
      BOOTSTRAP_ARGS+=("$1")
      shift
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
require_cmd curl
require_cmd tar
require_cmd mktemp

TMP_DIR="$(mktemp -d)"
cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

ARCHIVE="${TMP_DIR}/upstream.tar.gz"
URL="https://github.com/${REPO}/archive/${REF}.tar.gz"

echo "Downloading ${URL}"
if ! curl -fsSL "${URL}" -o "${ARCHIVE}"; then
  echo "Failed to download archive. Check REPO/REF and network." >&2
  exit 1
fi

tar xzf "${ARCHIVE}" -C "${TMP_DIR}"
TOP="$(tar tzf "${ARCHIVE}" | head -1 | cut -d/ -f1)"
SOURCE_ROOT="${TMP_DIR}/${TOP}"

if [[ ! -f "${SOURCE_ROOT}/scripts/bootstrap.sh" ]]; then
  echo "Archive did not contain scripts/bootstrap.sh at expected layout." >&2
  exit 1
fi

export REXY_VIBING_RECORD_REPO="${REPO}"
export REXY_VIBING_RECORD_REF="${REF}"

echo "Bootstrapping into ${TARGET_PATH} from ${REPO}@${REF}"
"${SOURCE_ROOT}/scripts/bootstrap.sh" "${TARGET_PATH}" "${BOOTSTRAP_ARGS[@]}"
