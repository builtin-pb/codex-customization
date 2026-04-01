# Events And Interactivity

Use this reference when the task depends on events, slash commands, buttons, shortcuts, or modal submissions.

## Core rule

Slack expects a fast acknowledgment path. Acknowledge first, then do slower work asynchronously.

## Covers

- Events API subscriptions
- HTTP request URLs
- Socket Mode event delivery
- Slash commands
- Shortcuts
- Block actions
- View submissions

## Design guidance

- Choose one narrow event set instead of subscribing broadly.
- Design handlers to be idempotent when retries or duplicate delivery matter.
- Keep request verification enabled for inbound HTTP traffic.
- Use modals for structured input; use messages for lightweight interaction; use App Home for persistent app state.

## Decision notes

- HTTP request URLs fit conventional web backends and public distribution better.
- Socket Mode fits local development and restricted network environments better, but it is not a default recommendation for publicly distributed apps.

## Official sources

- Events API overview: https://docs.slack.dev/apis/events-api/
- Event listening with Bolt JS: https://docs.slack.dev/tools/bolt-js/concepts/event-listening
- Using HTTP request URLs: https://docs.slack.dev/apis/events-api/using-http-request-urls/
- Using Socket Mode: https://docs.slack.dev/apis/events-api/using-socket-mode
- Slash commands: https://docs.slack.dev/interactivity/implementing-slash-commands/
- Acknowledging requests in Bolt JS: https://docs.slack.dev/tools/bolt-js/concepts/acknowledge
- Verify requests from Slack: https://docs.slack.dev/authentication/verifying-requests-from-slack/
