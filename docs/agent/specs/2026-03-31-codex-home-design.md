# Portable Codex Home Design

**Date:** 2026-03-31

## Goal

Turn this repository into the source of truth for the user-managed portion of `~/.codex`, with a one-command setup that recreates a working Codex home on another machine by symlinking repo-owned content into place.

## Scope

Initial scope is limited to skills and agents.

Out of scope for the first pass:
- `rules/`
- `scripts/`
- `memories/`
- caches, logs, sessions, databases, auth files, and other generated state
- Codex-managed default/system content that may change with Codex updates

## Requirements

1. This repository defines the live layout for tracked skills and agents.
2. `~/.codex` on a machine should point back to this repository via symlinks for tracked paths.
3. The repo must not depend on external layout generators or upstream installers to define which skills or agents exist.
4. The repo must document provenance for every tracked skill and agent.
5. The setup flow should be a single command run from the repo root.
6. Future agents working in this repo should have clear instructions for how to update the layout and provenance records safely.

## Design

### Ownership Model

The repository owns the managed Codex layout directly.

Tracked content will live under a repo-controlled tree, then be symlinked into `~/.codex`. The repo contents, not external upstreams, define what is present on the machine.

This means:
- a skill or agent is available because it exists in this repo
- upstream origin is recorded as metadata only
- copying or adapting an external item makes it repo-owned from that point on

### Planned Repository Structure

```text
.
├── AGENTS.md
├── README.md
├── bootstrap/
│   └── setup.sh
├── catalog/
│   ├── agents.toml
│   └── skills.toml
└── home/
    ├── agents/
    └── skills/
```

Notes:
- `home/skills/` is the tracked source for live `~/.codex/skills/`
- `home/agents/` is the tracked source for live `~/.codex/agents/` if agents are present
- `catalog/*.toml` records provenance and maintenance metadata
- `bootstrap/setup.sh` creates and updates symlinks into `~/.codex`

### Provenance Model

Every tracked skill and agent gets a catalog entry.

Proposed provenance states:
- `local`: written by the user in this repo
- `imported`: copied from an external source and kept substantially unchanged
- `adapted`: copied from an external source and modified by the user
- `forked`: originally external, now intentionally maintained as an independent repo-owned variant

Each manifest entry should include:
- item id
- type (`skill` or `agent`)
- repo path
- status
- source kind (`local`, `codex-system`, `external-repo`, `copied-from-home`, etc.)
- source path or source repo URL when known
- upstream version, commit, or date when known
- short notes describing user changes and maintenance expectations

The manifests are documentation and maintenance control files. They do not cause installation behavior by themselves; the repo tree does.

### Import Policy

The first import should be conservative and explicit.

Import into repo-owned layout:
- clearly user-maintained or explicitly desired skills
- clearly user-maintained or explicitly desired agents

Do not import into repo-owned layout:
- `.system/` Codex default skills
- caches, logs, sessions, sqlite/state files, auth, temp files, and snapshots
- metadata files whose purpose is Codex runtime bookkeeping rather than user-maintained configuration

Current known observations from `~/.codex`:
- local custom origin currently includes `skills-maintenance`
- Codex system skills live under `~/.codex/skills/.system`
- additional externally sourced skills currently exist under origin-grouped locations such as `wshobson-agents-extracted`

Initial implementation should copy only the selected repo-owned content into `home/skills/` and `home/agents/`, then record provenance in `catalog/`.

### Setup Behavior

`bootstrap/setup.sh` will:

1. determine the repository root from the script location
2. create `~/.codex` if it does not exist
3. create a timestamped backup directory for any conflicting real files or directories at tracked target paths
4. create symlinks from tracked repo paths into `~/.codex`
5. leave unmanaged Codex paths alone
6. print a summary of linked paths, backed-up conflicts, and unmanaged paths

The setup script will not:
- download or install upstream skills
- reconstruct Codex-managed default content
- overwrite user data silently

### AGENTS.md Responsibilities

`AGENTS.md` should define the maintenance contract for this repository.

It should instruct future agents to:
- treat this repo as the source of truth for managed Codex state
- read `AGENTS.md`, `README.md`, `catalog/skills.toml`, `catalog/agents.toml`, and `bootstrap/setup.sh` before changing layout or provenance
- update provenance manifests whenever adding, importing, adapting, renaming, or deleting a tracked skill or agent
- avoid importing whole upstream trees unless explicitly requested
- preserve the symlink-based deployment model
- keep unmanaged Codex runtime state out of the repo unless the user explicitly expands scope later

## Tradeoffs

### Why repo-owned layout instead of external installers

Pros:
- exact portability
- deterministic machine setup
- no hidden dependency on upstream layout changes
- provenance stays visible even after local edits

Cons:
- imported external content becomes the user's responsibility to curate
- upstream updates are manual and should be recorded deliberately

### Why manifests in addition to directory structure

Directory structure alone shows what exists, but not why it exists or where it came from.

The catalog files provide:
- maintenance context
- update guidance
- auditability for copied or adapted content
- a place to record intentional divergence from upstream

## Initial Execution Plan

After this design is approved, implementation should:

1. initialize git in this repository
2. create the repo structure
3. import the selected skills and agents into `home/`
4. create provenance manifests
5. write `AGENTS.md` and `README.md`
6. add the bootstrap script
7. verify the setup flow against the current machine

## Self-Review

- No placeholder sections remain.
- Scope is intentionally limited to skills and agents only.
- The ownership model, provenance model, and setup behavior are internally consistent.
- The design keeps Codex-managed defaults out of the repo-owned live layout unless the user explicitly chooses to vendor them later.
