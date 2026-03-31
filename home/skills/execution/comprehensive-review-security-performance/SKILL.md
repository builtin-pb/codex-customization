---
name: comprehensive-review-security-performance
description: Use when a broad review needs a dedicated pass over security, unsafe data handling, hot paths, concurrency, and scalability risks
---

# Comprehensive Review Security Performance

## Overview

Security and performance often meet at the same sharp edges: validation, resource use, caching, concurrency, and operational failure modes. Review them together when the interactions matter.

## Security Checks

- auth and authorization gaps
- unvalidated input, unsafe deserialization, or injection risk
- secrets exposure, weak crypto handling, or permissive config
- unsafe dependency or supply-chain choices
- sensitive data leakage in logs, errors, or responses

## Performance Checks

- hot paths with avoidable work
- expensive queries, N+1 access, or missing pagination
- blocking I/O, oversized payloads, or poor batching
- cache misses, invalidation hazards, or stale-cache bugs
- race conditions, deadlocks, lock contention, or stateful scaling barriers

## Reporting

Capture:

- exploit or failure scenario
- expected production impact
- why the issue is likely, not just possible
- the smallest credible remediation path

## Severity Lens

- `Critical`: clear exploit, outage, or data-loss risk
- `High`: realistic production vulnerability or major performance failure
- `Medium`: important but less immediate operational risk
