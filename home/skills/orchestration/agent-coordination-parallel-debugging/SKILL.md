---
name: agent-coordination-parallel-debugging
description: Use when the user has asked for parallel debugging and there are multiple plausible root-cause hypotheses worth testing independently
---

# Agent Coordination Parallel Debugging

## Overview

Parallel debugging works when the problem has competing explanations. Give each agent one hypothesis to prove or kill, then compare evidence before choosing a fix.

## Hypothesis Set

Common buckets:

- logic defect
- state or lifecycle bug
- data or schema mismatch
- integration or boundary failure
- environment or configuration issue
- resource or concurrency problem

## Assignment Rule

One hypothesis per agent. Do not give multiple agents the same theory unless you are intentionally verifying a critical path twice.

## Required Output Per Agent

- the hypothesis being tested
- the strongest supporting evidence
- the strongest disconfirming evidence
- commands, files, or traces examined
- current confidence: `high`, `medium`, or `low`
- next diagnostic step if unresolved

## Evidence Standard

- Prefer direct evidence over speculation
- Penalize hypotheses that require multiple unverified assumptions
- Treat “cannot reproduce” as weak evidence, not a conclusion
- Reject fixes that do not explain the observed symptom

## Synthesis

1. Compare hypotheses side by side.
2. Eliminate explanations contradicted by evidence.
3. Prefer the theory that explains the full symptom set with the fewest assumptions.
4. Only then choose the repair path.

## When To Stop

Stop parallel debugging when one hypothesis is strongly supported and the others are materially weaker, or when further delegation would just repeat the same inspection.
