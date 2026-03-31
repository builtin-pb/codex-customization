---
name: agent-coordination-task-coordination
description: Use when multi-agent work is active and you need to track dependencies, rebalance uneven streams, or decide when to pause and re-plan
---

# Agent Coordination Task Coordination

## Overview

Once work is split, manage it like a dependency graph. The main job is to keep unblocked work moving and stop wasted effort early.

## Dependency Language

- `unblocked`: can proceed immediately
- `blocked`: waiting on a contract, answer, or file owner
- `critical path`: controls the next integration milestone
- `sidecar`: useful parallel work that does not block the next local step

## Good Coordination Moves

- keep the critical path local unless a clean delegation exists
- give idle agents new sidecar work only if it advances the main task
- send integration updates only to affected workers
- regroup when the original split no longer matches reality

## Rebalancing Signals

- one stream is done while another is overloaded
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
- current owner of each stream
- blockers and who can clear them
- next integration point
- whether to continue, rebalance, or collapse back to local execution
