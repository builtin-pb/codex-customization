---
name: agent-coordination
description: Use when the user explicitly wants delegated or parallel agent work and the task needs team composition, coordination, or result synthesis
---

# Agent Coordination

## Overview

Use this collection only when the user explicitly asks for subagents, delegation, or parallel work. The goal is to split work cleanly, keep the critical path moving, and synthesize results before acting on them.

## When To Use

- The user asks for multi-agent work, delegation, or parallel investigation
- The task can be split into independent review, research, debugging, or implementation streams
- The main risk is coordination quality, overlap, or result synthesis

## Do Not Use

- When the user did not ask for subagents
- When one urgent blocker controls the very next step
- When multiple workers would edit the same files without a clear ownership plan

## Routing

- `agent-coordination-team-composition` for choosing the team shape and size
- `agent-coordination-parallel-debugging` for competing-hypothesis bug hunts
- `agent-coordination-parallel-feature-development` for implementation splits
- `agent-coordination-multi-reviewer` for parallel reviews
- `agent-coordination-task-coordination` for dependency tracking and rebalancing

## Core Rules

1. Prefer the smallest team that can make progress in parallel.
2. Keep blocking work local unless delegation still saves time overall.
3. Give each write-heavy task explicit ownership.
4. Ask subagents focused questions with bounded outputs.
5. Synthesize results locally before choosing the next action.

## Recommended Shapes

- `2 agents`: compare two hypotheses, review from two dimensions, or split one feature into two clean slices
- `3 agents`: common default for review or debugging when you need broader coverage
- `4+ agents`: only when ownership is disjoint and coordination cost is justified
