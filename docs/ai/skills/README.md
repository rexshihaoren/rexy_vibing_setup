# Portable Skills Standard

This directory is the canonical source for reusable agent skills in this repository.
It is model-agnostic and IDE-agnostic.

## Scope

These skills are intended to be usable with Codex, DeepSeek, Gemini, and Claude, across Trae/Cursor/other agent runtimes.

## Skill Contract

Each skill lives at:

`docs/ai/skills/<skill-name>/SKILL.md`

Optional companion files (examples, templates, scripts) stay in the same directory.

## Available Skills

- `grill-me`
- `grill-with-docs`
- `tdd`
- `diagnose`
- `caveman`
- `zoom-out`
- `improve-codebase-architecture`

## Portable Invocation Protocol

When a user asks for a skill (explicitly or by intent), the agent should:

1. Resolve skill name from request/intention.
2. Read `docs/ai/skills/<skill-name>/SKILL.md`.
3. Apply the skill instructions as higher-priority workflow guidance for the current task.
4. Load companion files referenced by that skill when needed.

## Adapter Targets

- Trae runtime target: `.trae/skills/`
- Canonical source: `docs/ai/skills/`

Use `scripts/generate_trae_adapter.sh` to refresh runtime adapters from canonical source.
