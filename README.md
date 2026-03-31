# codex-customization

This repository is a curated, maintainable collection of Codex skills and root-level agents. It also includes a convenient setup flow for linking the managed portion of that collection into `~/.codex`, but setup is a supporting detail rather than the main point of the repo.

## Purpose

The central problem this repository is trying to solve is not installation. It is maintenance.

A large skill collection is hard to keep coherent. Overlap creeps in. Conflicts appear across abstraction levels. A new skill may look good in isolation while quietly making the whole collection harder to reason about. This repo exists to keep that cluster organized, reviewable, and maintainable over time.

The managed `home/` tree is the source of truth for what this repository actively curates:
- skills under `home/skills/`
- root-level agents under `home/agents/`
- the managed global Codex instructions under `home/AGENTS.md`

The surrounding catalog and setup files exist to support that maintenance model:
- `catalog/` records provenance and maintenance metadata
- `bootstrap/` links the managed repo-owned content into `~/.codex`

## Philosophy

The skill collection is organized into four classes:
- `technology`
- `execution`
- `orchestration`
- `alignment`

This is not just a filing system. It is a conflict-management system.

The goal of the classification is to keep as many skills as possible orthogonal:
- technology skills should usually be plug-and-play and self-contained
- execution skills should focus on how to perform a task well without being tied to one stack
- orchestration skills should focus on how to split work across agents for throughput and latency
- alignment skills should focus on how the agent should collaborate with its leader

When the classes are used correctly, it becomes easier to:
- spot overlaps before they become contradictions
- decide whether a new skill belongs here at all
- keep instruction boundaries legible
- understand where conflicts are most likely to appear

## Skill Classes

### Technology Skills

Technology skills contain knowledge or sources of knowledge for parts of a technology stack. They may include docs, APIs, repos, best practices, and links to those sources.

These are usually the most self-contained skills in the repo. They are often maintained upstream by official developers or strong external maintainers, then curated here because they are useful and fit the managed collection cleanly.

Default rule:
- prefer `technology` unless a skill clearly belongs in one of the process-oriented classes below

### Execution Skills

Execution skills contain instructions for doing work well:
- writing code
- reviewing code
- reading papers
- writing UI
- brainstorming
- writing plans
- writing skills

They are technology-agnostic and broadly reusable across projects, even when they operate at different abstraction levels.

These skills are often the largest source of conflict in a collection like this. They can overlap across task families, scope levels, or quality standards. That is why they need especially careful review for duplication, contradiction, and unclear boundaries.

### Orchestration Skills

Orchestration skills teach the agent how to split work into subtasks and coordinate multiple agents to maximize throughput and minimize end-to-end latency.

They may overlap with execution skills at the edges, but the emphasis is different:
- execution skills emphasize how to perform a task well
- orchestration skills emphasize how to divide and coordinate the work

These skills exist because human attention is expensive, latency matters, and parallel review or verification is often worth the extra tokens.

### Alignment Skills

Alignment skills teach the agent how to make the leader happy, whether that leader is the user or another agent.

They cover questions like:
- when to ask for clarifications
- when to act end-to-end without stopping
- how to respect standing preferences
- how to reduce prompt burden for the leader

These skills are about collaboration quality and leader effort, not task-specific domain knowledge.

## Why This Organization Exists

The four-class split exists because different kinds of skill conflicts need different handling.

- Technology skills are numerous but usually low-conflict, so isolating them removes a large amount of noise.
- Execution skills are broadly applicable and often somewhat objective, but they are also the biggest source of overlap and contradiction.
- Orchestration skills are specialized around acceleration and parallelism, which is a distinct concern from single-agent execution quality.
- Alignment skills encode how the agent should behave toward its leader, which is a different kind of guidance again.

This structure does not eliminate conflicts, but it makes them easier to see, reason about, and review.

## What Belongs In This Repo

This repo is for skills and root-level agents that are worth maintaining as part of a coherent collection.

Good candidates usually have these properties:
- they fit one of the four classes clearly
- they add meaningful capability without creating avoidable overlap
- they are maintainable over time
- their provenance can be recorded clearly
- they improve the collection more than they complicate it

This repo does not primarily exist to store runtime state or machine-specific clutter. It does not currently manage:
- `rules/`
- `scripts/`
- `memories/`
- caches, logs, sessions, databases, auth files, or other runtime state
- Codex system defaults under `~/.codex/skills/.system`, which are intentionally left unmanaged

## Repo Layout

- `home/skills/<classification>/<skill-id>/`: repo-owned managed skills
- `home/agents/`: repo-owned managed root-level agents
- `home/AGENTS.md`: repo-owned managed global Codex instructions
- `catalog/skills.toml`: provenance and maintenance records for tracked skills
- `catalog/agents.toml`: provenance and maintenance records for tracked root-level agents
- `bootstrap/setup.sh`: setup helper that links managed content into `~/.codex`

The repo classification folders are organizational metadata. Live deployment into `~/.codex/skills/` remains flat by skill id.

## Onboarding

If you are new to this repo, the shortest useful path is:

1. Read this file for the collection model and classification philosophy.
2. Read [AGENTS.md](AGENTS.md) for the maintainer workflow and review expectations.
3. Inspect `home/skills/`, `home/agents/`, and the `catalog/` records to understand what is currently curated.
4. Run `bash bootstrap/setup.sh` if you want to link the managed collection into your live `~/.codex`.

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
- symlink the repo-owned `home/AGENTS.md` file into `~/.codex/AGENTS.md`
- prune stale managed skill symlinks that no longer exist under `home/skills/`
- leave unmanaged Codex state outside the repo-owned layout untouched

## Provenance

- `catalog/skills.toml` records the origin and maintenance status of each tracked skill.
- `catalog/agents.toml` records the origin and maintenance status of each tracked root-level agent.
- Nested agents shipped inside a skill are tracked with that skill rather than as root-level agents.
