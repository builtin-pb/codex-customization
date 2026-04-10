---
name: repo-to-paper-rough-draft
description: Use when the only source material is a research repo, experiment outputs, and notes, and a rough first paper draft needs to be created before section-level rewriting and polish.
version: 2.0.0
author: Orchestra Research
license: MIT
tags: [Academic Writing, Rough Drafts, Research Repos, Citations, LaTeX, Paper Scaffolding]
dependencies: [semanticscholar, arxiv, habanero, requests]
---

# Repo To Paper Rough Draft

## Overview

Use this skill to turn a research codebase into a structurally useful first manuscript.

This skill is intentionally narrow. Its job is to produce a rough draft with the right sections, claims, evidence inventory, and citation placeholders. It is **not** the primary skill for polished section writing, reviewer-facing clarity, or final submission quality. After producing the rough draft, hand off to `research-paper-writing`.

## When To Use

- There is no real paper draft yet
- The main source of truth is code, configs, experiment outputs, notes, or a research repo
- You need a first-pass manuscript fast so a stronger writing skill can refine it

## Do Not Use

- For paragraph-level polishing, flow, or reviewer-facing presentation
- For final section rewriting after a draft already exists
- For adversarial self-review before submission

Those jobs belong to `research-paper-writing`.

## Core Workflow

1. Inspect the repo and identify the likely contribution.
2. Inventory evidence, citations, and writing assets already present.
3. Build a rough paper scaffold around the strongest supported story.
4. Mark gaps aggressively instead of polishing around them.
5. Hand the draft to `research-paper-writing` for real writing work.

## Rough-Draft Rules

1. Prefer structural completeness over prose quality.
2. Write in clear technical language, but do not spend time polishing cadence or paragraph flow.
3. Never invent citations. Use `references/citation-workflow.md` and leave explicit placeholders when verification fails.
4. Pull existing citations and terminology from the repo before searching externally.
5. If the target venue is known, start from the closest local template under `templates/`. If unknown, draft in venue-agnostic section form.
6. Any claim not clearly supported by current results must be weakened, marked tentative, or tagged as a TODO.
7. Surface missing experiments, missing baselines, and narrative uncertainty explicitly.

## Repo-First Intake

Start from the repository, not from writing style.

Check:
- `README.md`, docs, and notes for the intended contribution
- `results/`, `outputs/`, `experiments/`, logs, and figures for evidence
- config files and scripts for method details
- existing `.bib` files, arXiv links, DOIs, and citations already referenced in the repo

Use:
- `references/citation-workflow.md` for citation verification
- `references/checklists.md` to notice major missing paper components
- `references/writing-guide.md` only for lightweight framing, not polishing

## Output Contract

When using this skill, return:

1. A one-sentence contribution hypothesis.
2. A rough paper outline with section purposes.
3. A rough draft of title, abstract, introduction, method, experiments, related work, and limitations.
4. A claim-and-evidence inventory for major claims.
5. A TODO list covering citation gaps, missing evidence, and sections that need `research-paper-writing` refinement.

## Handoff To `research-paper-writing`

Before switching skills, summarize:

- the draft file or draft text produced
- the main contribution framing you chose
- unsupported or weakly supported claims
- missing citations and experimental gaps
- which sections need the most rewriting

The next skill should assume the rough draft exists and focus on rewriting, flow, clarity, and reviewer-facing quality.
