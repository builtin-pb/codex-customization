---
name: skills-maintenance
description: Use when you need to inspect skill provenance, refresh generated skill inventories, add or remove a skill origin, record local customizations, or plan safe updates without stale registry docs.
---

# Skills Maintenance

Maintain the local skills installation from generated state, not memory.

## Core Rule

Do not hand-edit generated inventory files.

Generated outputs:
- `~/.codex/SKILLS-ORIGINS.md`
- `~/.codex/SKILLS-ORIGINS.json`
- `~/.codex/skills-by-origin/`

Edit the source-of-truth config instead, then regenerate.

## Source of Truth

Configuration lives here:
- `~/.codex/skills/skills-maintenance/data/origins.json`
- `~/.codex/skills/skills-maintenance/data/origin-overrides.json`

Generator:

```bash
python3 ~/.codex/skills/skills-maintenance/scripts/refresh_registry.py
```

## When to Use

Use this skill when you need to:
- see where skills came from
- check which skills are customized locally
- refresh inventory after installs, removals, or edits
- add a new origin
- remove an old origin
- plan update steps without losing local patches

## Workflow

1. Read the two config files.
2. Inspect current disk state if needed.
3. Update config, not generated docs.
4. Run the refresh script.
5. Read the generated registry and grouped view to confirm the result.

## Add or Remove Origins

To add a new origin:
- decide how it is discovered on disk
- add an origin entry to `origins.json`
- record origin-specific notes or skill customizations in `origin-overrides.json`
- install or link the actual skills
- run the refresh script

To remove an origin:
- remove or unlink the installed skills
- remove its config entry or overrides
- run the refresh script

## Keep State Fresh

Run the refresh script after:
- installing skills
- removing skills
- editing upstream-cloned skills
- changing which local skills are considered custom
- changing provenance notes or customization notes

If registry docs and disk state disagree, regenerate immediately.
