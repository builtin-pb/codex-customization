---
name: slack-development
description: Use when building or modifying Slack apps, bots, slash commands, Block Kit interfaces, OAuth installs, Socket Mode or Events API integrations, workflow steps, or Slack AI assistant experiences
---

# Slack Development

## Overview

This skill is the repo's broad entrypoint for Slack app development. It is language-agnostic, treats Bolt for JavaScript and Bolt for Python as the primary implementation paths, and uses official Slack docs and SDKs as the source of truth.

Use this skill to decide how a Slack app should be structured, which Slack surfaces and APIs apply, and which constraints matter for the chosen delivery model. Treat marketplace, workflow, and Socket Mode limits as decision guidance unless the user explicitly wants them enforced as hard requirements.

## When to Use This Skill

This skill activates for tasks involving:
- Building a Slack bot, app, or integration
- Adding slash commands, event listeners, shortcuts, actions, modals, or Home tabs
- Designing or debugging Block Kit payloads
- Choosing between Events API HTTP delivery and Socket Mode
- Configuring app manifests, scopes, and Slack CLI workflows
- Designing OAuth installs or public distribution paths
- Building workflow steps or Slack automations
- Building Slack AI or assistant-style experiences

## Recommended Starting Path

For most new Slack apps:
1. Start with an app manifest and only the scopes/features actually needed.
2. Choose Bolt JS or Bolt Python unless the user already committed to another SDK.
3. Choose HTTP request URLs for public or marketplace-facing apps; choose Socket Mode only when its operational tradeoffs are acceptable.
4. Decide whether the app is internal-only, multi-workspace private distribution, or public distribution before designing OAuth and runtime boundaries.

## Core Decisions

### JS vs Python

- Open `references/bolt-js.md` when the user is working in Node.js, TypeScript, or existing JavaScript infrastructure.
- Open `references/bolt-python.md` when the user is working in Python services, notebooks, data pipelines, or existing Python infrastructure.
- Keep examples and reasoning language-agnostic in the main flow unless the user asks for a concrete implementation.

### HTTP vs Socket Mode

- Prefer HTTP request URLs for public distribution, marketplace work, or conventional web deployments.
- Prefer Socket Mode for internal tooling, local development convenience, or environments where inbound HTTP exposure is awkward.
- Do not treat Socket Mode as the default for broad Slack guidance. It is an architectural choice with distribution consequences.

### Internal vs Distributed App

- Internal workspace app: optimize for speed, lower OAuth complexity, and tighter scope design.
- Private multi-workspace distribution: design installation storage, re-install flows, and scope changes deliberately.
- Public distribution: review Slack's distribution constraints early and avoid architecture choices that conflict with them.

### Classic App vs AI App

- Standard app: events, commands, actions, modals, Home tabs, workflows.
- AI app: assistant events, split-view surfaces, streaming UX, feedback flows, Slack context retrieval, and different scopes/events.
- Open `references/ai-apps.md` when the request involves agents, assistants, copilots, or chat-within-Slack experiences.

## Build Areas

### App Configuration

Use app manifests as the portable source of truth for scopes, features, event subscriptions, interactivity, and workflow capabilities. Open `references/manifests-and-cli.md` when the task involves bootstrapping a new app, cloning configuration between environments, or reasoning about scopes/features before code exists.

### Events and Interactivity

Use `references/events-and-interactivity.md` for:
- Events API subscriptions
- slash commands
- shortcuts
- block actions
- modal submissions
- ack timing and asynchronous follow-up

### Block Kit and Surfaces

Use `references/block-kit.md` for:
- composing messages
- modals
- App Home
- validating block choices and limits
- deciding when UI belongs in a message versus a modal versus Home

### OAuth and Distribution

Use `references/oauth-and-distribution.md` for:
- installation flows
- scope planning
- installation storage
- public distribution constraints
- deciding whether workflow steps, Socket Mode, or other features conflict with the intended distribution path

### Workflows and Automations

Use `references/workflows-and-steps.md` for:
- Slack workflows and custom workflow steps
- deciding whether a task belongs in a workflow versus a command or event flow
- workflow-step hosting and execution implications
- surfacing public-distribution limits as guidance when workflow steps are involved

## Sharp Edges

- Slack interactions usually require a fast `ack()` path. Slow business logic belongs after acknowledgment.
- Scope sprawl is a design bug. Request the minimum scopes needed for the current feature set.
- Retries and duplicate deliveries happen. Design event handling to be idempotent where it matters.
- Request verification and secret handling are baseline requirements, not optional hardening.
- Block Kit has surface-specific limits. Avoid designing payloads that only work accidentally.
- Socket Mode, workflow steps, and AI app features have deployment and distribution implications. Surface them as tradeoffs early instead of discovering them after implementation starts.
- Community examples are useful for patterns, but when they differ from official Slack docs, prefer the official docs.

## Reference Map

### `references/manifests-and-cli.md`

Open when defining a new app, choosing scopes and features, or deciding how to bootstrap local development.

### `references/events-and-interactivity.md`

Open when implementing event listeners, slash commands, actions, shortcuts, modals, or any flow that depends on timely acknowledgments.

### `references/block-kit.md`

Open when designing Slack UI payloads, validating block composition, or deciding which Slack surface should host a workflow.

### `references/oauth-and-distribution.md`

Open when installation, token storage, multi-workspace support, private/public distribution, or Slack Marketplace compatibility matters.

### `references/workflows-and-steps.md`

Open when the request involves Slack workflows, custom workflow steps, or automation design that may affect hosting and distribution choices.

### `references/bolt-js.md`

Open when the implementation should use Bolt for JavaScript or TypeScript.

### `references/bolt-python.md`

Open when the implementation should use Bolt for Python.

### `references/ai-apps.md`

Open when the request involves assistants, agents, streaming responses, split view, or Slack-native AI app capabilities.
