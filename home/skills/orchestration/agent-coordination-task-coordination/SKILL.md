---
name: agent-coordination-task-coordination
description: Use when multi-agent work is active and you need to track dependencies, rebalance uneven streams, or decide when to pause and re-plan
---

# Agent Coordination Task Coordination

## Overview

Once work is split, manage it like a dependency graph plus an active work queue. The main job is to keep unblocked work moving, refill productive lanes as agents finish, and stop wasted effort early.

## Dependency Language

- `unblocked`: can proceed immediately
- `blocked`: waiting on a contract, answer, or file owner
- `critical path`: controls the next integration milestone
- `sidecar`: useful parallel work that does not block the next local step

## Good Coordination Moves

- keep the critical path local unless a clean delegation exists
- treat agents as a rolling stream: when one finishes, integrate, reassign, or deliberately leave the slot empty
- give idle agents new sidecar work only if it advances the main task
- keep an active window sized to real ready work instead of doing one big spawn and waiting blindly
- send integration updates only to affected workers
- regroup when the original split no longer matches reality

## Rebalancing Signals

- one stream is done while another is overloaded
- ready work exists but no agent owns it
- multiple agents are inspecting the same artifact
- blockers cascade from a missing contract or ownership gap
- the cost of integration is now higher than the remaining work

## Pause-And-Replan Triggers

- file ownership is no longer disjoint
- a new dependency invalidates the original split
- unresolved findings change the implementation direction
- synthesis shows the delegated work answered the wrong question

## Useful Output Format

- active streams
- ready queue and open slots
- current owner of each stream
- blockers and who can clear them
- next integration point
- whether to continue, rebalance, or collapse back to local execution
