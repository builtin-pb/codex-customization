---
name: comprehensive-review-testing-docs
description: Use when a broad review needs a dedicated pass over test gaps, flaky-test risk, missing edge cases, and stale or misleading documentation
---

# Comprehensive Review Testing Docs

## Overview

Review whether critical behavior is actually protected by tests and whether the docs still describe reality. Missing coverage and stale docs are both regression multipliers.

## Testing Pass

Look for:

- critical paths with no direct tests
- error paths, boundary cases, and concurrency cases left untested
- tests coupled to implementation details instead of behavior
- flaky indicators such as timing assumptions, shared state, or over-mocking
- security and performance-sensitive paths that lack targeted coverage

## Documentation Pass

Look for:

- README, setup, or deployment steps that no longer match the code
- API docs, examples, or schemas that drifted from implementation
- missing notes around migrations, breaking changes, or operational constraints
- complex logic with no local explanation where one is needed

## Stale-Doc Heuristics

- docs mention old flags, endpoints, env vars, or filenames
- examples use outdated signatures or payload shapes
- the documented workflow would fail if followed literally

## Output

For each finding, state what is untested or stale, why it matters, and the smallest useful repair.
