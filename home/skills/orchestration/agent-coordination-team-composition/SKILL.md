---
name: agent-coordination-team-composition
description: Use when delegated or parallel work needs team sizing, role selection, or a read-versus-write split
---

# Agent Coordination Team Composition

## Overview

Build the smallest team that covers the required perspectives. Most tasks need two or three agents, not a swarm.

## Team Presets

- `Review team`: security, architecture, and performance or testing reviewers
- `Debug team`: one agent per plausible root-cause hypothesis
- `Feature team`: one implementer per disjoint ownership slice plus a local integrator
- `Research team`: multiple scoped explorers collecting independent evidence

## Sizing Heuristics

- Start with `2` agents for compare-and-contrast work
- Use `3` when the task benefits from distinct dimensions
- Use `4` only when the write scopes or research questions are clearly separate
- Avoid larger teams unless integration cost is obviously low

## Read-Heavy Versus Write-Heavy

- Read-heavy work parallelizes well: review, discovery, debugging, and source comparison
- Write-heavy work needs ownership boundaries before spawning
- Mixed read/write tasks should separate discovery from implementation

## Role Selection

- Assign specialists by dimension, not by vague seniority
- Keep one local owner responsible for synthesis and final decisions
- Prefer explorers for bounded codebase questions and workers for isolated implementation

## Failure Modes

- Too many agents doing the same readback
- Agents blocked on a shared file or interface nobody owns
- Parallelism applied to work that is actually sequential
- No local synthesis, which turns parallel results into noise
