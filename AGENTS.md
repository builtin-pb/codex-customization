# AGENTS.md

This file is the maintainer guide for the managed portion of the portable Codex home. Treat it as the operating contract for changing the collection safely.

For the user-facing explanation of why this repository exists and how the skill classes are organized, read `README.md` first. This file is about maintenance, not onboarding.

Before changing tracked skills, agents, setup behavior, or provenance, read:
- `README.md`
- `AGENTS.md`
- `catalog/skills.toml`
- `catalog/agents.toml`
- `bootstrap/setup.sh`

## Mission

Maintain this repo as a coherent, reviewable, and durable collection of skills and root-level agents.

The main maintenance risk is not syntax or setup breakage. It is collection drift:
- overlapping skills with unclear boundaries
- conflicting instructions across nearby skills
- stale metadata or stale provenance
- mismatches between repo docs and live managed behavior

Keep `README.md` and repo `AGENTS.md` focused on durable model, workflow, and review guidance. Current inventory, provenance specifics, and live tracked items belong in the catalogs and repo tree unless they are needed to explain a stable invariant.

## Source Of Truth

1. The repo-owned `home/` tree defines what is live on a machine.
2. If a managed skill, root-level agent, or global `AGENTS.md` file should exist in `~/.codex`, it must be present here under `home/`.
3. Managed skills live under `home/skills/<classification>/<skill-id>/`.
4. The supported skill classifications are `technology`, `execution`, `orchestration`, and `alignment`.
5. Deployment into `~/.codex/skills/` stays flat by skill id; the repo classification folders are organizational metadata, not live nested install paths.
6. `catalog/skills.toml` `repo_path` values must include the classification folder and match the file tree exactly.
7. Upstream origin is metadata only. The repo tree is authoritative.
8. `~/.codex/skills/.system` is intentionally unmanaged and must be preserved.
9. Managed skills are linked into `~/.codex/skills/` while preserving unmanaged entries already present there.
10. `~/.codex/agents/` remains repo-managed through this repository.
11. `bootstrap/setup.sh` is the only supported setup entry point.
12. Do not rewrite setup behavior back to whole-directory replacement for skills.
13. Do not import whole upstream trees unless the user explicitly requests that scope and the tree is being curated into repo-owned paths.
14. Do not add runtime state, caches, logs, sessions, auth files, or other generated data unless the user explicitly requests it.

## Classification Rules

- `technology`: skill content about a technology, framework, API, model, tool, cloud service, library, or externally maintained body of technical knowledge
- `execution`: technology-agnostic task guidance for doing work well, such as planning, coding, debugging, reviewing, brainstorming, paper writing, or similar execution workflows
- `orchestration`: guidance for splitting work across multiple agents, assigning ownership, coordinating dependencies, and reducing end-to-end latency in multi-agent execution
- `alignment`: guidance about how the agent should collaborate with its leader, especially around initiative, verification discipline, clarification behavior, and other behavioral alignment expectations

Classification rules for ambiguous cases:
- prefer `technology` for framework-specific knowledge, even if the framework is about agents or orchestration
- prefer `execution` for single-agent task quality and output standards
- prefer `orchestration` only when the core value is multi-agent decomposition or coordination
- prefer `alignment` only when the core value is leader satisfaction, behavioral guardrails, or completion discipline

## Maintenance Workflows

### Add A Skill

When adding a tracked skill:
- choose the classification first
- create the repo-owned skill under `home/skills/<classification>/<skill-id>/`
- update `catalog/skills.toml`
- record the best available source path, source repo, commit, or date
- mark the item as `local`, `imported`, `adapted`, or `forked`
- add notes if the repo-owned version intentionally diverges from upstream
- review for overlap and conflict before considering the addition complete

### Modify A Skill

When modifying a tracked skill:
- keep the classification and file path aligned unless you are intentionally reclassifying it
- update `catalog/skills.toml` if provenance, status, source details, or divergence notes changed
- review the edited skill for single-skill quality and collection-level impact
- check nearby skills and docs for contradictions introduced by the change

### Move Or Rename A Skill

When moving or renaming a tracked skill:
- move the repo-owned directory under `home/skills/<classification>/`
- update `catalog/skills.toml` `repo_path`
- re-check the classification against the new location
- review any references in docs or neighboring skills that may still use the old name or path

### Remove A Skill

When removing a tracked skill:
- remove the repo-owned skill directory
- remove or update the matching catalog record
- review whether any docs or neighboring skills still refer to it
- check whether the removal leaves an intentional gap or unresolved overlap elsewhere in the collection

### Add Or Modify A Root-Level Agent

When changing a root-level agent under `home/agents/`:
- update `catalog/agents.toml`
- record provenance and divergence notes
- review the agent for overlap with skills or repo-level instructions
- check whether the root-level agent should remain root-level or belong inside a skill instead

### Change Repo-Level Documentation

When changing `README.md` or repo `AGENTS.md`:
- keep `README.md` user-facing and philosophy-oriented
- keep repo `AGENTS.md` maintainer-facing and workflow-oriented
- check for drift against `home/AGENTS.md`
- make sure the repo model, classification rules, and maintenance expectations still line up

### Change Setup Behavior

When changing `bootstrap/setup.sh`:
- preserve the symlink-based deployment model
- preserve unmanaged entries, especially `~/.codex/skills/.system`
- keep the docs aligned with actual behavior
- verify that the setup change does not silently expand managed scope

## Review Workflow

Run this review workflow whenever you add, remove, move, rename, import, or materially modify a tracked skill, root-level agent, or core maintenance doc.

### 1. Review The Item Itself

For the changed skill or agent, check:
- is its purpose clear
- is its scope tight enough
- is its abstraction level clear
- is the classification still correct
- does it clearly say what it is for and when to use it
- does it rely on stale paths, stale tool names, or stale repo assumptions
- does it include avoidable duplication or vague instructions

### 2. Review For Overlap And Conflict

Check nearby skills and agents for:
- duplicated purpose
- conflicting instructions
- ambiguous precedence
- partial overlap across abstraction levels
- silent drift where two items now claim the same job in slightly different language

Conflicts are especially likely in `execution` skills and at the boundaries between `execution`, `orchestration`, and `alignment`.

### 3. Review Cross-File Consistency

Check the changed item against:
- `catalog/skills.toml`
- `catalog/agents.toml`
- `README.md`
- repo `AGENTS.md`
- `home/AGENTS.md`
- `bootstrap/setup.sh`

Look for:
- path mismatches
- classification mismatches
- outdated source or provenance notes
- contradictions in repo model or deployment description
- mismatches between repo maintenance rules and live managed instructions

### 4. Review Collection-Level Impact

Ask:
- does this change make the collection easier or harder to reason about
- does it increase hidden coupling
- does it blur boundaries between classes
- does it make future additions safer or riskier
- does it improve maintainability more than it increases complexity

An individually good skill can still be a bad collection change if it adds too much overlap or ambiguity.

### 5. Review Supporting Docs And Metadata

If the change affects repo-owned content or provenance:
- update the matching record in `catalog/skills.toml` or `catalog/agents.toml`
- keep `repo_path` aligned with the file tree under `home/`
- update notes when the repo-owned version intentionally diverges from upstream
- check whether `README.md` or repo `AGENTS.md` needs wording changes to stay accurate

### 6. Review Setup Assumptions

If the change affects managed layout or deployment assumptions:
- verify that `bootstrap/setup.sh` still matches the described model
- verify that the docs still describe the flat live deployment into `~/.codex/skills/`
- verify that unmanaged `.system` content remains preserved

## Common Pitfalls

- A `technology` skill drifting into process guidance that belongs in `execution`.
- An `execution` skill quietly owning orchestration policy instead of task quality.
- An `orchestration` skill redefining what “good execution” means instead of how work should be split.
- An `alignment` skill encoding preferences that should live in `home/AGENTS.md` instead.
- Two skills solving the same problem at different abstraction levels without making the boundary explicit.
- Adding a skill that is individually useful but makes the collection less orthogonal.
- Reclassifying a skill without updating `catalog/skills.toml` and related references.
- Updating setup behavior or repo docs so they no longer match each other.
- Letting repo `AGENTS.md` and `home/AGENTS.md` drift into conflicting mental models.
- Leaving imported source details, paths, or divergence notes stale after a change.

## Provenance

Whenever you add, remove, import, rename, or modify a tracked skill or agent:
- update the matching record in `catalog/skills.toml` or `catalog/agents.toml`
- keep `repo_path` aligned with the file tree under `home/`
- record the best available source path, source repo, commit, or date
- mark the item as `local`, `imported`, `adapted`, or `forked`
- add notes when the repo-owned version intentionally diverges from upstream

## Completion Standard

Do not consider maintenance work complete until:
- the repo tree under `home/` is correct
- the matching catalog entries are correct
- the classification is still defensible
- the changed item passes the review workflow above
- repo docs and live managed behavior still describe the same system
