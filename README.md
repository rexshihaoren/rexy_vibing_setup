# rexy_vibing_setup

Portable, minimal coding-agent setup for multi-IDE and multi-model workflows.

## What This Repo Provides

- Canonical policy file: `AGENTS.md`
- Compatibility shims: `AGENT.md`, `CLAUDE.md`, `CURSOR.md`, `.cursorrules`
- Canonical skills source: `docs/ai/skills/`
- Trae adapter sync script: `scripts/generate_trae_adapter.sh`
- Cursor adapter sync script: `scripts/generate_cursor_adapter.sh`
- Project bootstrap script: `scripts/bootstrap.sh`
- Remote install script: `scripts/install.sh` (curl-friendly; pins upstream in `.rexy-vibing-version`)
- In-repo updater: `scripts/rexy-vibing-update.sh` (re-bootstrap from a newer GitHub ref)

## Defaults Included

- Intent-based skill auto-routing
- Caveman mode enabled by default
- Caveman safety exceptions and auto-resume behavior
- Model-agnostic skill protocol for Codex, DeepSeek, Gemini, Claude

## Remote install (portable)

Install from GitHub into another repository (writes `.rexy-vibing-version` so you can update later):

```bash
curl -fsSL "https://raw.githubusercontent.com/rexshihaoren/rexy_vibing_setup/main/scripts/install.sh" | bash -s -- /absolute/path/to/target-repo
```

Install from a fork or a specific upstream ref (installer script can stay on upstream `main`):

```bash
curl -fsSL "https://raw.githubusercontent.com/rexshihaoren/rexy_vibing_setup/main/scripts/install.sh" | bash -s -- /absolute/path/to/target-repo --repo myfork/rexy_vibing_setup --ref main
```

Environment overrides (same semantics as flags): `REXY_VIBING_REPO`, `REXY_VIBING_REF`.

## Update an existing install

From the **target** repository root:

```bash
./scripts/rexy-vibing-update.sh --dry-run
./scripts/rexy-vibing-update.sh --ref main
```

`-y` skips the confirmation prompt. Adapter folders (`.trae/skills`, `.cursor/skills`) are regenerated only if they already exist in the target repo.

## Bootstrap Usage

Copy this setup from a **local clone** of this repository into another repository:

```bash
./scripts/bootstrap.sh /absolute/path/to/target-repo
```

To record upstream metadata for `rexy-vibing-update.sh` when using local bootstrap:

```bash
REXY_VIBING_RECORD_REF="$(git rev-parse HEAD)" REXY_VIBING_RECORD_REPO="rexshihaoren/rexy_vibing_setup" \
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
- `scripts/bootstrap.sh`
- `scripts/generate_trae_adapter.sh`
- `scripts/generate_cursor_adapter.sh`
- `scripts/install.sh`
- `scripts/rexy-vibing-update.sh`
- `.rexy-vibing-version` when `REXY_VIBING_RECORD_REF` is set (see above)

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
