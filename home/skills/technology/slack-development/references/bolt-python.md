# Bolt For Python

Use this reference when the user is building a Slack app in Python.

## When Bolt Python is a good default

- Existing Python service or worker
- Python-heavy integration stack
- Need official framework support for commands, events, actions, and modals
- Need a practical path from prototype to production without adopting a community wrapper

## Typical responsibilities Bolt Python handles

- listener routing
- request verification integration
- acknowledgment flow
- OAuth helpers
- Socket Mode support
- Slack client integration for follow-up API calls

## Keep in mind

- Keep the fast-ack rule even when handler code is concise.
- Separate Slack transport concerns from domain/business logic once the app grows.
- Use the official Python Slack SDK docs when you need lower-level API details outside framework helpers.

## Official sources

- Bolt Python concepts: https://docs.slack.dev/tools/bolt-python/
- Bolt Python GitHub repo: https://github.com/slackapi/bolt-python
- Python Slack SDK GitHub repo: https://github.com/slackapi/python-slack-sdk
