---
name: comprehensive-review-architecture
description: Use when a broad review needs a dedicated pass over boundaries, coupling, dependency direction, abstractions, and architectural consistency
---

# Comprehensive Review Architecture

## Overview

Review whether the code fits the system around it and whether the structure makes future changes safer or harder.

## Check For

- unclear component boundaries or mixed concerns
- dependency direction that pulls low-level code upward
- circular or awkward coupling
- abstractions that are missing, leaky, or overbuilt
- APIs, schemas, or contracts that are hard to evolve safely
- divergence from established project patterns without good reason

## Questions

- Does each module have a clear responsibility?
- Is shared logic placed at the right boundary?
- Will this structure make future changes cheaper or more expensive?
- Does the design match the scale of the problem?

## Findings

For each issue capture:

- impact on change safety or correctness
- where the boundary problem appears
- whether the fix is local refactoring or a broader design change

## Avoid

- architecture opinions disconnected from repo conventions
- “use pattern X” advice without a concrete defect or payoff
