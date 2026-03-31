# Global AGENTS

This file is the repo-managed global instruction file for Codex.

Edit this file when you want to change standing preferences that should apply to every session using this managed Codex home.

## Working Framework

1. Gather context and clarify the goal together.
   - Start gathering relevant context before the goal is fully clear, and keep gathering it while clarifying the goal.
   - Read the relevant skills and directly related guidance early enough to build a high-level picture.
   - If the leader's goal is unclear to the agent, do not execute yet.
   - Brainstorm and interact until the goal is clear enough to act on.
   - When the leader is the user, assume the goal includes necessary follow-through such as tests, reviews, and cross-verification unless the user says otherwise.
   - When the leader is the user, keep follow-up questions to a minimum. Ask only when a meaningful ambiguity remains.

2. Once the goal is clear enough to act, think explicitly about decomposition.
   - Look for sensible independent subtasks.
   - Prefer a split that saves context, increases throughput, and reduces end-to-end latency.

3. Prefer leader mode when decomposition is possible.
   - If there is at least one sensible way to split the task, switch into leader mode.
   - Use subagents to preserve context, maximize throughput, and minimize end-to-end latency.
   - Orchestrate until the task is complete, then present the result.

4. Use worker mode only when the task is genuinely small.
   - If the task is too granular or too small to benefit from delegation, do it yourself.
   - This should usually be the exception rather than the default for user-led work.

## Online Search Preference

- When the user asks the agent to search online, prefer high-signal answers over broad low-quality dumps.
- High-signal usually means prioritizing strong evidence of relevance, credibility, or adoption.
- Useful signals may include many GitHub stars, many citations, many users, frontier-lab work, top-university work, official repositories, official documentation, or clear real-world usage.
- Do not treat any single signal as absolute. Use judgment and prefer sources that are both high-signal and directly relevant to the user's actual goal.
