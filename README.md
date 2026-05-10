# rexy_vibing_setup

Portable, minimal coding-agent setup for multi-IDE and multi-model workflows.

## What This Repo Provides

- Canonical policy file: `AGENTS.md`
- Compatibility shims: `AGENT.md`, `CLAUDE.md`, `CURSOR.md`, `.cursorrules`
- Canonical skills source: `docs/ai/skills/`
- Trae adapter sync script: `scripts/generate_trae_adapter.sh`
- Cursor adapter sync script: `scripts/generate_cursor_adapter.sh`
- Project bootstrap script: `scripts/bootstrap.sh`

## Defaults Included

- Intent-based skill auto-routing
- Caveman mode enabled by default
- Caveman safety exceptions and auto-resume behavior
- Model-agnostic skill protocol for Codex, DeepSeek, Gemini, Claude

## Bootstrap Usage

Copy this setup into another repository:

```bash
./scripts/bootstrap.sh /absolute/path/to/target-repo
```

Also generate Trae runtime adapter (`.trae/skills`) in target repo:

```bash
./scripts/bootstrap.sh /absolute/path/to/target-repo --with-trae
```

Also generate Cursor runtime adapter (`.cursor/skills`) in target repo:

```bash
./scripts/bootstrap.sh /absolute/path/to/target-repo --with-cursor
```

Flags can be combined:

```bash
./scripts/bootstrap.sh /absolute/path/to/target-repo --with-trae --with-cursor
```

What bootstrap copies:

- `AGENTS.md`
- `AGENT.md`
- `CLAUDE.md`
- `CURSOR.md`
- `.cursorrules`
- `docs/ai/skills/`
- `scripts/generate_trae_adapter.sh`
- `scripts/generate_cursor_adapter.sh`

## Working Model

- Edit skills only in `docs/ai/skills/` (canonical).
- If Trae adapter is needed, run:

```bash
./scripts/generate_trae_adapter.sh
```

- If Cursor adapter is needed, run:

```bash
./scripts/generate_cursor_adapter.sh
```

- `.trae/skills/` and `.cursor/skills/` are generated adapter output and should not be edited manually.

## Credits

This setup ports and adapts skills from Matt Pocock's repository:

- [mattpocock/skills](https://github.com/mattpocock/skills)
