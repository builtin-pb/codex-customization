# AGENTS.md

This repository is the source of truth for the managed portion of the portable Codex home plan.

Before changing tracked skills, agents, setup behavior, or provenance, read:
- `AGENTS.md`
- `README.md`
- `catalog/skills.toml`
- `catalog/agents.toml`
- `bootstrap/setup.sh`

## Source Of Truth

1. The repo-owned `home/` tree defines what is live on a machine.
2. If a skill or agent should exist in `~/.codex`, it must be present here under `home/`.
3. Upstream origin is metadata only. The repo tree is authoritative.
4. `~/.codex/skills/.system` is intentionally unmanaged and must be preserved.
5. Managed skills are linked into `~/.codex/skills/` while preserving unmanaged entries already present there.
6. `~/.codex/agents/` remains repo-managed through this repository.
7. Do not rewrite setup behavior back to whole-directory replacement for skills.
8. Do not import whole upstream trees unless the user explicitly requests that scope and the tree is being curated into repo-owned paths.
9. Do not add runtime state, caches, logs, sessions, auth files, or other generated data unless the user explicitly requests it.
10. The maintained imported origins are currently `orchestra`, `superpowers`, and `wshobson-agents-extracted`.
11. `skills-maintenance` is intentionally not tracked as a live skill in this repo; its provenance workflow is folded into `AGENTS.md`, `README.md`, and the catalog files.

## Provenance

Whenever you add, remove, import, rename, or modify a tracked skill or agent:
- update the matching record in `catalog/skills.toml` or `catalog/agents.toml`
- keep `repo_path` aligned with the file tree under `home/`
- record the best available source path, source repo, commit, or date
- mark the item as `local`, `imported`, `adapted`, or `forked`
- add notes when the repo-owned version intentionally diverges from upstream

Current imported root agent:
- `home/agents/code-reviewer.md` from `superpowers`

Current imported skill clusters:
- `orchestra`
- `superpowers`
- `wshobson-agents-extracted`

## Setup

- `bootstrap/setup.sh` is the only supported setup entry point.
- Preserve the symlink-based deployment model into `~/.codex`.
- Back up conflicts before replacing live managed paths.
- Leave unmanaged Codex paths untouched.
- Prune stale managed skill symlinks that point back into the repo but no longer exist under `home/skills/`.

## Import Maintenance

- `bootstrap/import_current_home.sh` is an explicit maintenance/import tool, not the normal machine-setup command.
- It currently imports maintained content from `~/.orchestra/skills`, `~/.codex/superpowers/skills`, `~/.codex/superpowers/agents`, and `~/.agents/skills`.
- Do not point the importer back at the live managed `~/.codex/skills` container as its primary source for Orchestra content; use the canonical upstream roots instead.
