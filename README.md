# rexy_vibing_setup

Minimal coding-agent setup for Trae and Cursor.

## What This Repo Provides

- Canonical policy file: `AGENTS.md`
- Compatibility shims: `AGENT.md`, `CLAUDE.md`, `CURSOR.md`, `.cursorrules`
- Canonical skills source: `docs/ai/skills/`
- Trae adapter generator: `scripts/generate_trae_adapter.sh`
- Cursor adapter generator: `scripts/generate_cursor_adapter.sh`
- Per-project attach script: `scripts/attach.sh`

## Defaults Included

- Intent-based skill auto-routing
- Caveman mode enabled by default
- Caveman safety exceptions and auto-resume behavior
- Model-agnostic skill protocol for Codex, DeepSeek, Gemini, Claude

## Recommended Usage

Keep one canonical clone on each machine:

```bash
git clone https://github.com/rexshihaoren/rexy_vibing_setup ~/rexy_vibing_setup
```

Attach into any project:

```bash
~/rexy_vibing_setup/scripts/attach.sh /absolute/path/to/target-repo --ide both
```

Only Trae:

```bash
~/rexy_vibing_setup/scripts/attach.sh /absolute/path/to/target-repo --ide trae
```

Only Cursor:

```bash
~/rexy_vibing_setup/scripts/attach.sh /absolute/path/to/target-repo --ide cursor
```

Default `attach.sh` behavior:

- If target root has none of `AGENTS.md`, `AGENT.md`, `CLAUDE.md`, `CURSOR.md`, `.cursorrules`, copy `AGENTS.md` plus all shims
- If target root already has `AGENTS.md`, copy any missing shims and do not overwrite `AGENTS.md`
- If target root has any of `AGENT.md`, `CLAUDE.md`, `CURSOR.md`, `.cursorrules`, copy none and print a skip message
- Generate or refresh requested runtime adapters

- `.trae/skills/`
- `.cursor/skills/`

These adapter directories should be ignored by git and not edited manually.

## Update Flow

Update canonical repo:

```bash
cd ~/rexy_vibing_setup
git pull
```

Re-attach into any project you want refreshed:

```bash
~/rexy_vibing_setup/scripts/attach.sh /absolute/path/to/target-repo --ide both
```

To skip policy-file copy entirely:

```bash
~/rexy_vibing_setup/scripts/attach.sh /absolute/path/to/target-repo --ide both --policy never
```

## Direct Generator Usage

If you want to run generators directly:

```bash
./scripts/generate_trae_adapter.sh --target /absolute/path/to/target-repo
./scripts/generate_cursor_adapter.sh --target /absolute/path/to/target-repo
```

Edit skills only in `docs/ai/skills/`. Agents should prefer that canonical path first, then fall back to `.cursor/skills/` or `.trae/skills/` only when the canonical path is absent. Adapters are generated output.

## Credits

This setup ports and adapts skills from Matt Pocock's repository:

- [mattpocock/skills](https://github.com/mattpocock/skills)
