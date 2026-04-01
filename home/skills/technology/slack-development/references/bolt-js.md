# Bolt For JavaScript

Use this reference when the user is building a Slack app with Node.js or TypeScript.

## When Bolt JS is a good default

- Existing Node.js backend
- TypeScript-first codebase
- Need quick iteration on commands, events, actions, and modals
- Need official Slack framework support rather than a community wrapper

## Typical responsibilities Bolt JS handles

- request routing
- listener registration
- acknowledgment flow
- middleware/context plumbing
- OAuth helpers
- Socket Mode support

## Keep in mind

- Fast `ack()` still matters even though Bolt simplifies the handler surface.
- Treat Bolt as the framework layer, not as a substitute for app architecture.
- Use the official Slack SDK docs when you need lower-level Web API details beyond the framework examples.

## Official sources

- Bolt JS getting started: https://docs.slack.dev/tools/bolt-js/getting-started/
- Bolt JS concepts: https://docs.slack.dev/tools/bolt-js/
- Bolt JS AI apps: https://docs.slack.dev/tools/bolt-js/concepts/ai-apps/
- Bolt JS custom steps: https://docs.slack.dev/tools/bolt-js/tutorials/custom-steps/
- GitHub repo: https://github.com/slackapi/bolt-js
- Node Slack SDK: https://github.com/slackapi/node-slack-sdk
