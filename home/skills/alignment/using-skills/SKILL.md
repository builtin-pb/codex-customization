---
name: using-skills
description: Use when starting a session or when you need to determine how local skills should be discovered and applied in this environment
---

<EXTREMELY-IMPORTANT>
If you think there is even a 1% chance a skill might apply to what you are doing, you ABSOLUTELY MUST invoke the skill.

IF A SKILL APPLIES TO YOUR TASK, YOU DO NOT HAVE A CHOICE. YOU MUST USE IT.

This is not negotiable. This is not optional. You cannot rationalize your way out of this.
</EXTREMELY-IMPORTANT>

## Instruction Priority

Managed skills override generic default behavior, but **user instructions always take precedence**:

1. **User's explicit instructions** (`AGENTS.md`, other repo instruction files, direct requests) — highest priority
2. **Managed skills** — override default system behavior where they conflict
3. **Default system prompt** — lowest priority

If `AGENTS.md` says "don't use TDD" and a skill says "always use TDD," follow `AGENTS.md`. The user is in control.

## How to Access Skills

**In Codex:** Open the skill's `SKILL.md` first. Then treat the entire skill directory as in scope, not just `SKILL.md`. If there is even a 1% chance that a referenced file, template, checklist, example, script, or other skill file is relevant, open it too before proceeding, unless the opened skill explicitly requires staged or selective loading.

**In other environments:** Use the closest native skill-loading mechanism for that host.

## Platform Adaptation

Some imported skills still use legacy host tool names. In Codex, interpret them using `references/codex-tools.md`. Gemini CLI users can use `references/gemini-tools.md`.

# Using Skills

## The Rule

**Invoke relevant or requested skills BEFORE any response or action.** Even a 1% chance a skill might apply means that you should invoke the skill to check. If an invoked skill turns out to be wrong for the situation, you don't need to use it.

Do not stop after the first matching skill. Do not stop after the broadest skill. Open every skill that has even a 1% chance of being relevant, unless an already-opened skill explicitly forbids invoking additional skills at the current stage. In that case, record the blocked candidates and open them at the first stage the gating skill allows.

Apply the same rule inside each opened skill. If there is even a 1% chance that a file mentioned by the skill is relevant, open it before proceeding. This includes files in `references/`, plus mentioned templates, checklists, examples, and scripts, unless the skill explicitly requires staged or selective reference loading. In that case, follow the narrower skill-local rule after opening the top-level skill.

## Enforcement

Before proceeding from skill discovery into planning, research, implementation, file edits, or a final answer, explicitly state:

1. Which skills you opened.
2. Which referenced files inside those skills you opened.
3. Which candidate skills or referenced files you surfaced during the scan but did not open.

If you did not open a surfaced skill or referenced file, give a one-sentence reason, including when the reason is that it fell below the 1% threshold or was blocked by a gating skill.

Do not proceed until this accounting is complete.

```dot
digraph skill_flow {
    "User message received" [shape=doublecircle];
    "About to EnterPlanMode?" [shape=doublecircle];
    "Already brainstormed?" [shape=diamond];
    "Invoke brainstorming skill" [shape=box];
    "Might any skill apply?" [shape=diamond];
    "Invoke Skill tool" [shape=box];
    "Announce: 'Using [skill] to [purpose]'" [shape=box];
    "Has checklist?" [shape=diamond];
    "Create TodoWrite todo per item" [shape=box];
    "Follow skill exactly" [shape=box];
    "Respond (including clarifications)" [shape=doublecircle];

    "About to EnterPlanMode?" -> "Already brainstormed?";
    "Already brainstormed?" -> "Invoke brainstorming skill" [label="no"];
    "Already brainstormed?" -> "Might any skill apply?" [label="yes"];
    "Invoke brainstorming skill" -> "Might any skill apply?";

    "User message received" -> "Might any skill apply?";
    "Might any skill apply?" -> "Invoke Skill tool" [label="yes, even 1%"];
    "Might any skill apply?" -> "Respond (including clarifications)" [label="definitely not"];
    "Invoke Skill tool" -> "Announce: 'Using [skill] to [purpose]'";
    "Announce: 'Using [skill] to [purpose]'" -> "Has checklist?";
    "Has checklist?" -> "Create TodoWrite todo per item" [label="yes"];
    "Has checklist?" -> "Follow skill exactly" [label="no"];
    "Create TodoWrite todo per item" -> "Follow skill exactly";
}
```

## Red Flags

These thoughts mean STOP—you're rationalizing:

| Thought | Reality |
|---------|---------|
| "This is just a simple question" | Questions are tasks. Check for skills. |
| "I need more context first" | Skill check comes BEFORE clarifying questions. |
| "Let me explore the codebase first" | Skills tell you HOW to explore. Check first. |
| "I can check git/files quickly" | Files lack conversation context. Check for skills. |
| "Let me gather information first" | Skills tell you HOW to gather information. |
| "This doesn't need a formal skill" | If a skill exists, use it. |
| "I remember this skill" | Skills evolve. Read current version. |
| "This doesn't count as a task" | Action = task. Check for skills. |
| "The skill is overkill" | Simple things become complex. Use it. |
| "I'll just do this one thing first" | Check BEFORE doing anything. |
| "I've already opened one broad skill" | Broad coverage is not enough. Open every plausible companion skill. |
| "The top-level SKILL.md is probably enough" | If a referenced file has even a 1% chance of mattering, open it. |
| "This feels productive" | Undisciplined action wastes time. Skills prevent this. |
| "I know what that means" | Knowing the concept ≠ using the skill. Invoke it. |

## Skill Priority

When multiple skills could apply, use this order after opening all skills required by the discovery rule:

1. **Process skills first** (brainstorming, debugging) - these determine HOW to approach the task
2. **Implementation skills second** (frontend-design, mcp-builder) - these guide execution

"Let's build X" → brainstorming first, then implementation skills.
"Fix this bug" → debugging first, then domain-specific skills.

## Skill Types

**Rigid** (TDD, debugging): Follow exactly. Don't adapt away discipline.

**Flexible** (patterns): Adapt principles to context.

The skill itself tells you which.

## User Instructions

Instructions say WHAT, not HOW. "Add X" or "Fix Y" doesn't mean skip workflows.
