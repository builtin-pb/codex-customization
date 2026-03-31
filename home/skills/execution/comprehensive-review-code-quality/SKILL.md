---
name: comprehensive-review-code-quality
description: Use when a broad review needs a dedicated pass over complexity, maintainability, duplication, error handling, and technical debt risks
---

# Comprehensive Review Code Quality

## Overview

Look for code that is hard to reason about, easy to break, or expensive to change. The point is not style purity; it is maintainability and defect risk.

## Check For

- deeply nested or high-branching logic
- long functions or classes with mixed responsibilities
- duplication that can diverge or hide inconsistent fixes
- fragile error handling, swallowed exceptions, vague failures
- hidden invariants and state transitions that are not enforced
- shortcuts that create technical debt around core paths

## Evidence To Capture

- the exact file and line where the risk appears
- why the current structure raises defect or maintenance cost
- whether the risk is a current bug, a regression hazard, or longer-term debt
- the smallest plausible fix direction

## Severity Lens

- `High`: likely bug or major regression risk
- `Medium`: meaningful maintenance or readability cost
- `Low`: cleanup candidate without near-term correctness risk

## Avoid

- generic “could be cleaner” commentary
- lint-style nits unless they hide a real maintenance problem
- proposing broad rewrites without a clear payoff
