---
name: agent-coordination-parallel-feature-development
description: Use when a feature may be divided into disjoint ownership slices with shared boundaries for parallel implementation
---

# Agent Coordination Parallel Feature Development

## Overview

Split implementation by ownership, not optimism. A parallel feature plan is good only if each worker can make progress without editing the same files.

## Decomposition Patterns

- `Vertical slice`: one worker owns a complete sub-feature end to end
- `By layer`: UI, business logic, and data layer are separate owners
- `By module`: ownership follows domain boundaries
- `Hybrid`: one worker owns shared infrastructure, others own feature slices

## Ownership Rules

- One owner per file
- Shared barrels, registries, and index files need a single owner
- If multiple streams need the same boundary, extract a contract file owned by one person

## Interface Contract Checklist

- names and signatures
- request and response shapes
- error behavior
- null and empty-state handling
- version or migration expectations
- test doubles or stubs needed for early progress

## Integration Risks

- hidden shared files such as exports, routing tables, or config
- silent contract drift between implementers
- tests written against stale interfaces
- one slice finishing early but blocked on an unowned dependency

## Replan Triggers

- repeated merge conflicts
- two workers blocked on each other
- a split that creates more coordination than implementation
- contract changes that invalidate downstream work
