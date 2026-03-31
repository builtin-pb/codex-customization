---
name: agent-coordination-multi-reviewer
description: Use when the user has asked for parallel review and the task needs separate reviewer perspectives such as security, architecture, performance, or testing
---

# Agent Coordination Multi Reviewer

## Overview

Parallel review is useful when each reviewer looks through a different lens. The value comes from coverage and synthesis, not from collecting overlapping comments.

## Common Review Dimensions

- code quality and maintainability
- architecture and dependency direction
- security and data handling
- performance and scalability
- testing and regression risk
- documentation and operational readiness

## Split Rules

- Give each reviewer one primary dimension
- Keep the review target identical unless the task explicitly scopes different areas
- Require file and line references when findings are concrete

## Deduplication Rules

- Merge duplicate findings under the most precise explanation
- Keep the highest justified severity when multiple reviewers report the same issue
- Fold symptom-only comments into the root-cause finding when possible

## Severity Calibration

- `Critical`: exploit, data loss, auth bypass, outage risk, or certain severe regression
- `High`: likely production bug, major missing coverage, major architectural flaw
- `Medium`: meaningful maintainability or correctness risk
- `Low`: minor issue or backlog-quality improvement

## Consolidated Output

Report findings first, ordered by severity. For each finding include:

- reviewer dimension
- file and line reference when available
- risk or regression
- short fix direction

Add a short summary only after the findings list.
