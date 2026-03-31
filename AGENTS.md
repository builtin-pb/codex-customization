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
3. Managed skills now live under `home/skills/<classification>/<skill-id>/`.
4. The supported skill classifications are `technology`, `execution`, `orchestration`, and `alignment`.
5. Deployment into `~/.codex/skills/` stays flat by skill id; the repo classification folders are organizational metadata, not live nested install paths.
6. `catalog/skills.toml` `repo_path` values must include the classification folder and match the file tree exactly.
7. When adding or moving a skill, choose its classification using the rules in "Skill Classification" below.
8. Upstream origin is metadata only. The repo tree is authoritative.
9. `~/.codex/skills/.system` is intentionally unmanaged and must be preserved.
10. Managed skills are linked into `~/.codex/skills/` while preserving unmanaged entries already present there.
11. `~/.codex/agents/` remains repo-managed through this repository.
12. Do not rewrite setup behavior back to whole-directory replacement for skills.
13. Do not import whole upstream trees unless the user explicitly requests that scope and the tree is being curated into repo-owned paths.
14. Do not add runtime state, caches, logs, sessions, auth files, or other generated data unless the user explicitly requests it.
15. The maintained imported origins are currently `orchestra`, `superpowers`, and `wshobson-agents-extracted`.
16. `skills-maintenance` is intentionally not tracked as a live skill in this repo; its provenance workflow is folded into `AGENTS.md`, `README.md`, and the catalog files.

## Skill Classification

- `technology`: Skill content about a technology, framework, API, model, tool, cloud service, library, or externally maintained body of technical knowledge. This is the default bucket unless a skill clearly belongs in one of the process buckets below.
- `execution`: Technology-agnostic task guidance for doing work well, such as planning, coding, debugging, reviewing, brainstorming, paper writing, or similar execution workflows.
- `orchestration`: Guidance for splitting work across multiple agents, assigning ownership, coordinating dependencies, and reducing end-to-end latency in multi-agent execution.
- `alignment`: Guidance about how the agent should collaborate with its leader, especially around initiative, verification discipline, clarification behavior, and other behavioral alignment expectations.

Classification rules for ambiguous cases:

- Prefer `technology` for framework-specific knowledge, even if the framework is about agents or orchestration.
- Prefer `execution` for single-agent task quality and output standards.
- Prefer `orchestration` only when the core value is multi-agent decomposition or coordination.
- Prefer `alignment` only when the core value is leader satisfaction, behavioral guardrails, or completion/verification discipline.

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
