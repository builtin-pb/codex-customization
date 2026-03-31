---
name: comprehensive-review-reporting
description: Use when broad review findings from multiple passes or reviewers need a final severity-ranked report and action plan
---

# Comprehensive Review Reporting

## Overview

The report should help someone act, not just read. Merge overlapping findings, rank them clearly, and keep the output findings-first.

## Output Order

1. Findings by severity
2. Short open questions or assumptions
3. Brief summary and action plan

## Deduplication

- Merge duplicate findings from different passes
- Keep the explanation with the strongest root-cause framing
- Preserve secondary dimensions only when they add real context

## Severity Buckets

- `Critical`: must fix immediately
- `High`: fix before release or before expanding scope
- `Medium`: schedule soon, likely next sprint
- `Low`: backlog or opportunistic cleanup

## Per-Finding Shape

- title
- severity
- category or review dimension
- file and line reference when available
- concrete risk
- short fix direction

## Action Plan

- start with critical and high issues
- group fixes that can be solved together
- separate immediate defects from longer-term debt
- call out missing tests or stale docs that should accompany the fix
