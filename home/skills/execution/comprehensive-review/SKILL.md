---
name: comprehensive-review
description: Use when reviewing a repo, module, or diff for broad code-health risks across quality, architecture, security, performance, testing, and documentation
---

# Comprehensive Review

## Overview

Run a broad repo-health review in focused passes, then synthesize the result into one findings-first report. Prioritize bugs, regressions, missing tests, stale docs, and operational risk over style commentary.

## Scope Targets

- entire repository
- specific module or subsystem
- recent diff or pull request
- one risky path such as auth, data migration, or caching

## Review Flow

1. Define what is in scope and what is out.
2. Review code quality and architecture.
3. Review security and performance.
4. Review testing and documentation.
5. Consolidate by severity and category.

## Supporting Skills

- `comprehensive-review-code-quality`
- `comprehensive-review-architecture`
- `comprehensive-review-security-performance`
- `comprehensive-review-testing-docs`
- `comprehensive-review-reporting`

## Rules

- Findings come first.
- Focus on defects, regressions, and missing coverage.
- Distinguish current bugs from longer-term cleanup.
- Do not pretend this is a background daemon or always-on scanner.
