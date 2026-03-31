---
name: executing-plans
description: Use when you have a written implementation plan ready to execute and want a disciplined execution workflow
---

# Executing Plans

## Overview

Load plan, review critically, execute all tasks, report when complete.

**The plan file is a live execution log.** As each step completes, edit the plan in place:
- Change that step from `- [ ]` to `- [x]`
- Add an `Observed:` line directly under the completed step
- Record the actual result, including verification output, deviations, and surprises encountered during implementation

Use `TodoWrite`/`update_plan` for live session state, but treat the plan markdown as the durable record another engineer should be able to read later.

**Announce at start:** "I'm using the executing-plans skill to implement this plan."

**Note:** If the current environment supports subagents cleanly, prefer `subagent-driven-development` for same-session execution. Use this skill when you intentionally want batched inline execution instead.

## The Process

### Step 1: Load and Review Plan
1. Read plan file
2. Review critically - identify any questions or concerns about the plan
3. If concerns: Raise them with your human partner before starting
4. If no concerns: Create TodoWrite and proceed

### Step 2: Execute Tasks

For each task:
1. Mark as in_progress
2. Follow each step exactly (plan has bite-sized steps)
3. Run verifications as specified
4. After a step and its required verification complete successfully, immediately edit the plan file:
   - Flip that step from `- [ ]` to `- [x]`
   - Write `Observed: ...` directly under it
   - Note what actually happened, including exact test/verification outcome and any surprises, deviations, or clean-up work required
5. If a step is attempted but not completed, leave it unchecked and add a brief `Blocked:` line under it with the reason
6. Mark task as completed

### Step 3: Complete Development

After all tasks complete and verified:
- Announce: "I'm using the finishing-a-development-branch skill to complete this work."
- **REQUIRED SUB-SKILL:** Use `finishing-a-development-branch`
- Follow that skill to verify tests, present options, execute choice

## When to Stop and Ask for Help

**STOP executing immediately when:**
- Hit a blocker (missing dependency, test fails, instruction unclear)
- Plan has critical gaps preventing starting
- You don't understand an instruction
- Verification fails repeatedly

**Ask for clarification rather than guessing.**

## When to Revisit Earlier Steps

**Return to Review (Step 1) when:**
- Partner updates the plan based on your feedback
- Fundamental approach needs rethinking

**Don't force through blockers** - stop and ask.

## Remember
- Review plan critically first
- Follow plan steps exactly
- Don't skip verifications
- Update the plan file immediately after each completed step; don't batch all checkbox edits at the end
- `Observed:` lines should capture what really happened, not what the plan predicted
- Reference skills when plan says to
- Stop when blocked, don't guess
- Never start implementation on main/master branch without explicit user consent

## Integration

**Required workflow skills:**
- **using-git-worktrees** - Optional isolation workflow when you intentionally want a separate workspace
- **writing-plans** - Creates the plan this skill executes
- **finishing-a-development-branch** - Complete development after all tasks
