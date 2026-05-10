# Agent Standard (Single Source Of Truth)

This file is the canonical agent instruction for this repository.
If another agent-specific file exists (`AGENTS.md`, `CLAUDE.md`, `CURSOR.md`, `.cursorrules`), it must defer to this file instead of duplicating rules.

## Objectives

- Make safe, minimal, high-signal changes.
- Prefer clarity over cleverness.
- Keep one source of truth for process and conventions.

## Working Style

- Understand first, then edit.
- Prefer small, reversible changes.
- Do not modify unrelated files.
- Keep configuration minimal and avoid redundant definitions.

## Code Change Rules

- Follow existing project style and structure.
- Avoid introducing new dependencies unless clearly justified.
- Update documentation when behavior or workflow changes.
- Run focused verification relevant to changed files.

## Skills

This repo stores reusable skills in a model-agnostic canonical location:

- `docs/ai/skills/`

Runtime adapters may mirror from canonical source, for example:

- Trae runtime path: `.trae/skills/`

Use these skills when relevant:

- `grill-me`
- `grill-with-docs`
- `tdd`
- `diagnose`
- `caveman`
- `zoom-out`
- `improve-codebase-architecture`

## Skill Portability

These skills are intended to work regardless of model family (Codex, DeepSeek, Gemini, Claude) by using a neutral prompt contract.

Portable protocol:

1. Resolve requested skill from user intent or explicit name.
2. Read `docs/ai/skills/<skill-name>/SKILL.md`.
3. Apply that skill as task workflow guidance.
4. Load any companion files referenced by that skill.

## Default Skill Behavior

- Use intent-based auto-routing by default (not explicit-name-only mode).
- Enable `caveman` response style by default.
- Allow explicit user override at any time.

### Caveman Safety Exceptions

Temporarily disable caveman mode for:

- Security warnings
- Destructive or irreversible action confirmations
- Ambiguous multi-step instructions where brevity may cause misread
- Any direct user request for clarification

After the clear/safe section is complete, auto-resume caveman mode.

Sync adapter targets from canonical source with:

- `scripts/generate_trae_adapter.sh`

## Priority Order

When instructions conflict, follow this order:

1. Direct user request
2. Safety and non-destructive behavior
3. This file (`AGENT.md`)
4. Tool-specific adapter files (`AGENTS.md`, `CLAUDE.md`, `CURSOR.md`, `.cursorrules`)
