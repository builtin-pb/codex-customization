# Managed Global AGENTS Design

**Date:** 2026-03-31

## Goal

Add a repo-managed, always-on instruction file for Codex preferences so this customization can define a single canonical global `AGENTS.md` and deploy it into `~/.codex`.

## Scope

In scope:
- one new repo-owned file at `home/AGENTS.md`
- setup support to deploy `home/AGENTS.md` to `~/.codex/AGENTS.md`
- documentation updates describing the new managed surface
- bootstrap tests covering installation, backup, and idempotence

Out of scope:
- managing `rules/` as a directory
- catalog entries for the global instruction file
- changing skill or agent provenance behavior
- changing how unmanaged runtime paths are preserved

## Requirements

1. The user can store standing preferences in one repo-owned file.
2. Running `bash bootstrap/setup.sh` installs those preferences into `~/.codex/AGENTS.md`.
3. Existing conflicting live files are backed up before replacement.
4. Re-running setup is idempotent.
5. Unmanaged paths such as `~/.codex/rules/` remain untouched.
6. The repository documentation clearly distinguishes this global instruction file from managed skills and managed agents.

## Options Considered

### Option 1: Manage `home/AGENTS.md`

Store a single canonical file at `home/AGENTS.md` and symlink it into `~/.codex/AGENTS.md`.

Pros:
- matches the user's desired mental model: one always-on file
- smallest expansion of the current repo contract
- consistent with the repo's existing symlink-based setup model

Cons:
- adds a new managed root path that must be documented and tested

### Option 2: Manage `home/rules/`

Create a repo-owned rules directory and deploy it into `~/.codex/rules/`.

Pros:
- leaves room for future decomposition into multiple files

Cons:
- larger scope than needed
- conflicts with the current repo boundary, which explicitly does not manage `rules/`
- weaker match for the user's stated preference for one canonical file

### Option 3: Encode preferences as an alignment skill

Place preferences in a managed skill under `home/skills/alignment/`.

Pros:
- uses an already supported managed surface

Cons:
- not inherently always-on
- conflates global policy with conditional skill invocation

## Chosen Design

Use option 1.

The repository will add a new top-level managed home artifact: `home/AGENTS.md`. This file is the source of truth for the user's always-on Codex preferences. Setup will install it as a symlink at `~/.codex/AGENTS.md`.

This keeps the model simple:
- `home/skills/` remains for skills
- `home/agents/` remains for root-level agents
- `home/AGENTS.md` becomes the single global instruction file

## Repository Changes

### File Layout

Planned managed layout:

```text
home/
├── AGENTS.md
├── agents/
└── skills/
```

### Documentation Contract

Update `AGENTS.md` and `README.md` to say that the managed Codex layout now includes:
- `home/skills/`
- `home/agents/`
- `home/AGENTS.md`

The docs should also state that:
- `home/AGENTS.md` is a global instruction file, not a skill and not a root-level agent
- catalog tracking still applies only to skills and root-level agents
- `rules/` remains unmanaged unless the repo scope is intentionally expanded later

## Setup Behavior

`bootstrap/setup.sh` should gain a small helper for managing a single root file, parallel to how it already manages the `agents/` root symlink.

Expected behavior:

1. Compute the managed source path for `home/AGENTS.md`.
2. Target `~/.codex/AGENTS.md`.
3. If the target is already the expected symlink, do nothing.
4. If the target exists as any other file or symlink, move it into the existing timestamped backup root.
5. Create a symlink from `~/.codex/AGENTS.md` to repo-owned `home/AGENTS.md`.
6. Include the path in the setup summary output.

This change must not affect the current behavior for:
- `~/.codex/skills/`
- `~/.codex/agents/`
- unmanaged root paths
- unmanaged skill entries

## Testing

Extend `tests/bootstrap/test_setup.sh` with coverage for:

1. Fresh install:
   - `~/.codex/AGENTS.md` is created as a symlink
   - the symlink target is `home/AGENTS.md`

2. Conflict handling:
   - an existing live `~/.codex/AGENTS.md` is backed up
   - the new symlink is created afterward

3. Idempotence:
   - a second setup run leaves the expected symlink in place
   - no extra backup is created when nothing changed

4. Preservation:
   - existing unmanaged paths such as `~/.codex/rules/runtime.txt` remain unchanged

## Tradeoffs

### Why not use a skill

Skills are the wrong abstraction for global standing preferences. They are organized content units intended to be invoked or routed, while the user's requirement is unconditional baseline behavior.

### Why not use `rules/`

Managing `rules/` would introduce a broader surface than the user asked for and would require extra policy about merge behavior, ordering, and multi-file composition. A single `home/AGENTS.md` gives the needed capability without inventing a new subsystem.

## Implementation Outline

After this design is approved for implementation:

1. create `home/AGENTS.md`
2. update `bootstrap/setup.sh` to link `AGENTS.md`
3. update `AGENTS.md`
4. update `README.md`
5. extend `tests/bootstrap/test_setup.sh`
6. run bootstrap tests

## Self-Review

- No placeholders remain.
- The design adds one managed surface and does not expand into `rules/`.
- Catalog responsibilities remain unchanged, which avoids forcing a non-skill, non-agent artifact into the provenance model.
- The setup and test changes are small and consistent with the existing symlink deployment model.
