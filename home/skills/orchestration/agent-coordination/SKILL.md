---
name: agent-coordination
description: Use when a task can benefit from delegated or parallel agent work and needs team composition, coordination, or result synthesis
---

# Agent Coordination

## Overview

Use this collection when a task has meaningful independent streams and multi-agent coordination is likely to reduce end-to-end latency. Treat multi-agent execution as a rolling stream, not a one-time spawn burst: start enough lanes to keep ready work moving, then refill or collapse those lanes as agents finish and new work opens up. The goal is to split work cleanly, keep the critical path moving, and synthesize results before acting on them.

## When To Use

- The task can be split into independent review, research, debugging, or implementation streams
- The main risk is coordination quality, overlap, or result synthesis
- The user has not prohibited delegation and the coordination overhead is justified

## Do Not Use

- When the user explicitly wants local-only execution
- When one urgent blocker controls the very next step
- When multiple workers would edit the same files without a clear ownership plan

## Routing

- `agent-coordination-team-composition` for choosing the team shape and size
- `agent-coordination-parallel-debugging` for competing-hypothesis bug hunts
- `agent-coordination-parallel-feature-development` for implementation splits
- `agent-coordination-multi-reviewer` for parallel reviews
- `agent-coordination-task-coordination` for dependency tracking and rebalancing

## Core Rules

1. Prefer the smallest active team that can keep ready work moving in parallel.
2. Keep blocking work local unless delegation still saves time overall.
3. Give each write-heavy task explicit ownership.
4. Ask subagents focused questions with bounded outputs.
5. Treat delegation as a stream: when an agent finishes, decide whether to integrate, refill that slot with the next ready slice, or let the lane go idle.
6. Synthesize results locally before choosing the next action.
7. When spawning a coordination-capable subagent that may split work further, include `Be parallel when appropriate` explicitly in the prompt.

## Recommended Shapes

- `2 agents`: compare two hypotheses, review from two dimensions, or split one feature into two clean slices
- `3-4 agents`: common starting range for review or debugging when you need broader coverage
- `5-8 agents`: acceptable when ownership or questions are clearly disjoint and the controller can keep the lanes fed
- `8+ agents`: only when integration cost stays low and you still have genuinely independent streams
