#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_file() {
  local path="$1"
  [[ -f "${path}" ]] || fail "missing file: ${path}"
}

assert_not_file() {
  local path="$1"
  [[ ! -f "${path}" ]] || fail "unexpected file: ${path}"
}

assert_dir() {
  local path="$1"
  [[ -d "${path}" ]] || fail "missing dir: ${path}"
}

assert_contains() {
  local needle="$1"
  local path="$2"
  grep -F "${needle}" "${path}" >/dev/null 2>&1 || fail "expected '${needle}' in ${path}"
}

assert_exit_nonzero() {
  local name="$1"
  shift
  set +e
  "$@" >/dev/null 2>&1
  local code=$?
  set -e
  [[ "${code}" -ne 0 ]] || fail "expected non-zero exit for ${name}"
}

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
POLICY_FILES=(AGENTS.md AGENT.md CLAUDE.md CURSOR.md .cursorrules)

assert_contains "Read \`docs/ai/skills/<skill-name>/SKILL.md\` if it exists." "${ROOT_DIR}/AGENTS.md"
assert_contains "Otherwise read \`.cursor/skills/<skill-name>/SKILL.md\` if it exists." "${ROOT_DIR}/AGENTS.md"
assert_contains "Otherwise read \`.trae/skills/<skill-name>/SKILL.md\` if it exists." "${ROOT_DIR}/AGENTS.md"

tmp="$(mktemp -d)"
cleanup() { rm -rf "${tmp}"; }
trap cleanup EXIT

target="${tmp}/proj"

bash "${ROOT_DIR}/scripts/generate_trae_adapter.sh" --target "${target}"
assert_dir "${target}/.trae/skills"
assert_file "${target}/.trae/skills/README.md"
assert_file "${target}/.trae/skills/caveman/SKILL.md"
assert_contains "Trae Skills Adapter" "${target}/.trae/skills/README.md"

bash "${ROOT_DIR}/scripts/generate_cursor_adapter.sh" --target "${target}"
assert_dir "${target}/.cursor/skills"
assert_file "${target}/.cursor/skills/README.md"
assert_file "${target}/.cursor/skills/caveman/SKILL.md"
assert_contains "Cursor Skills Adapter" "${target}/.cursor/skills/README.md"

rm -rf "${target}"
attach_output="$(bash "${ROOT_DIR}/scripts/attach.sh" "${target}" --ide both)"
assert_file "${target}/.trae/skills/caveman/SKILL.md"
assert_file "${target}/.cursor/skills/caveman/SKILL.md"
assert_contains "No policy files found; copying AGENTS.md and shims." <(printf "%s\n" "${attach_output}")
assert_contains "Creating Trae adapter." <(printf "%s\n" "${attach_output}")
assert_contains "Creating Cursor adapter." <(printf "%s\n" "${attach_output}")
for file_name in "${POLICY_FILES[@]}"; do
  assert_file "${target}/${file_name}"
done
assert_contains "Read \`docs/ai/skills/<skill-name>/SKILL.md\` if it exists." "${target}/AGENTS.md"
assert_contains "Otherwise read \`.cursor/skills/<skill-name>/SKILL.md\` if it exists." "${target}/AGENTS.md"
assert_contains "Otherwise read \`.trae/skills/<skill-name>/SKILL.md\` if it exists." "${target}/AGENTS.md"

attach_output="$(bash "${ROOT_DIR}/scripts/attach.sh" "${target}" --ide both)"
assert_contains "Existing policy file found (AGENTS.md); shims already present." <(printf "%s\n" "${attach_output}")
assert_contains "Refreshing Trae adapter." <(printf "%s\n" "${attach_output}")
assert_contains "Refreshing Cursor adapter." <(printf "%s\n" "${attach_output}")

rm -rf "${target}"
mkdir -p "${target}"
printf "project-owned\n" > "${target}/AGENTS.md"
attach_output="$(bash "${ROOT_DIR}/scripts/attach.sh" "${target}" --ide trae)"
assert_contains "Existing policy file found (AGENTS.md); copying missing shims." <(printf "%s\n" "${attach_output}")
assert_contains "project-owned" "${target}/AGENTS.md"
assert_file "${target}/AGENT.md"
assert_file "${target}/CLAUDE.md"
assert_file "${target}/CURSOR.md"
assert_file "${target}/.cursorrules"
assert_file "${target}/.trae/skills/caveman/SKILL.md"

rm -rf "${target}"
mkdir -p "${target}"
printf "project-owned\n" > "${target}/CLAUDE.md"
attach_output="$(bash "${ROOT_DIR}/scripts/attach.sh" "${target}" --ide trae)"
assert_contains "Existing policy file found (CLAUDE.md); skipped AGENTS/shims." <(printf "%s\n" "${attach_output}")
assert_file "${target}/CLAUDE.md"
assert_file "${target}/.trae/skills/caveman/SKILL.md"
assert_not_file "${target}/AGENTS.md"
assert_not_file "${target}/AGENT.md"
assert_not_file "${target}/CURSOR.md"
assert_not_file "${target}/.cursorrules"

rm -rf "${target}"
bash "${ROOT_DIR}/scripts/attach.sh" "${target}" --ide trae >/dev/null
assert_file "${target}/.trae/skills/caveman/SKILL.md"
[[ ! -d "${target}/.cursor/skills" ]] || fail "unexpected cursor adapter for --ide trae"

rm -rf "${target}"
bash "${ROOT_DIR}/scripts/attach.sh" "${target}" --ide cursor >/dev/null
assert_file "${target}/.cursor/skills/caveman/SKILL.md"
[[ ! -d "${target}/.trae/skills" ]] || fail "unexpected trae adapter for --ide cursor"

rm -rf "${target}"
bash "${ROOT_DIR}/scripts/attach.sh" "${target}" --with-trae >/dev/null
assert_file "${target}/.trae/skills/caveman/SKILL.md"
[[ ! -d "${target}/.cursor/skills" ]] || fail "unexpected cursor adapter for --with-trae"

rm -rf "${target}"
bash "${ROOT_DIR}/scripts/attach.sh" "${target}" --with-cursor >/dev/null
assert_file "${target}/.cursor/skills/caveman/SKILL.md"
[[ ! -d "${target}/.trae/skills" ]] || fail "unexpected trae adapter for --with-cursor"

rm -rf "${target}"
attach_output="$(bash "${ROOT_DIR}/scripts/attach.sh" "${target}" --policy never --ide cursor)"
assert_contains "Policy copy disabled (--policy never)." <(printf "%s\n" "${attach_output}")
assert_file "${target}/.cursor/skills/caveman/SKILL.md"
assert_not_file "${target}/AGENTS.md"

assert_exit_nonzero "attach invalid ide" bash "${ROOT_DIR}/scripts/attach.sh" "${target}" --ide nope
assert_exit_nonzero "attach conflicts (ide + with-trae)" bash "${ROOT_DIR}/scripts/attach.sh" "${target}" --ide both --with-trae
assert_exit_nonzero "attach invalid policy" bash "${ROOT_DIR}/scripts/attach.sh" "${target}" --policy nope

echo "OK"
