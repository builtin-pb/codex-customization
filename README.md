# codex-customization

Portable, repo-owned Codex home for managed skills and agents.

## Scope

This repository currently defines the managed Codex layout for:
- `home/skills/`
- `home/agents/`
- provenance and maintenance records under `catalog/`
- setup and bootstrap checks under `bootstrap/` and `tests/bootstrap/`

This repository does not currently manage:
- `rules/`
- `scripts/`
- `memories/`
- caches, logs, sessions, databases, auth files, or other runtime state
- Codex system defaults under `~/.codex/skills/.system`, which are intentionally left unmanaged

The active non-system skills are vendored under `home/skills/<classification>/<skill-id>/` as repo-owned content and are linked into the existing `~/.codex/skills/` container without replacing unmanaged entries there. The tracked external origins currently include `orchestra`, `superpowers`, `wshobson-agents-extracted`, `daymade-claude-code-skills`, and `getsentry-skills`. The root-level `home/agents/` tree is repo-managed and currently includes `code-reviewer.md` from `superpowers`.

## Skill Classification

Managed skills are organized into four bins:

- `technology`: externally maintained technology knowledge such as docs, APIs, repos, best practices, tools, libraries, models, and platform-specific guidance
- `execution`: technology-agnostic task guidance such as planning, coding, debugging, reviewing, brainstorming, paper writing, and similar execution workflows
- `orchestration`: multi-agent decomposition and coordination guidance focused on splitting work, assigning ownership, and minimizing end-to-end latency
- `alignment`: collaboration and behavioral guidance focused on initiative, clarification, verification, and other leader-alignment expectations

Classification rules:

- Default to `technology` unless the skill is primarily about process or behavior.
- Use `execution` for single-agent task quality and output standards.
- Use `orchestration` only when the main value is multi-agent coordination.
- Use `alignment` only when the main value is collaboration policy or verification/behavioral discipline.

The repo classification folders are organizational metadata. Live deployment into `~/.codex/skills/` remains flat by skill id.

`skills-maintenance` is intentionally not tracked as a live skill in this repo. Its provenance and update ideas were folded into `AGENTS.md`, `README.md`, and the catalog files instead.

## Setup

Run the setup command from the repo root:

```bash
bash bootstrap/setup.sh
```

The setup flow is intended to:
- create `~/.codex` if needed
- back up conflicting managed paths
- discover managed skill leaf directories under `home/skills/<classification>/` and symlink them into `~/.codex/skills/` while preserving `~/.codex/skills/.system`
- symlink the repo-owned `home/agents/` tree into `~/.codex/agents/`
- prune stale managed skill symlinks that no longer exist under `home/skills/`
- preserve unmanaged Codex state outside the repo-owned layout

`bootstrap/import_current_home.sh` is a separate maintenance tool for refreshing the repo from the canonical source trees, not the normal machine-setup command.

## Provenance

- `catalog/skills.toml` records the origin and maintenance status of each tracked skill.
- `catalog/agents.toml` records the origin and maintenance status of each tracked root-level agent.
- Nested agents shipped inside a skill are tracked with that skill rather than as root-level agents.
