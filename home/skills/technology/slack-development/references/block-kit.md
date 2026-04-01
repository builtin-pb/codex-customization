# Block Kit And Slack Surfaces

Use this reference when building rich Slack UI payloads.

## Surfaces

- Messages: lightweight interaction and notifications
- Modals: structured multi-field input
- App Home: persistent app dashboard or workflow hub

## Guidance

- Prefer messages for fast, contextual actions.
- Prefer modals when the user needs to enter or edit structured data.
- Prefer App Home when the app needs a durable landing surface independent of a specific message thread.

## Common pitfalls

- Overloading a single message with too many blocks or too much text
- Using modals for flows that should stay conversational
- Forgetting that different surfaces have different block limits
- Copying payloads from examples without checking surface compatibility

## Official sources

- Block Kit overview: https://docs.slack.dev/block-kit/
- Block reference: https://docs.slack.dev/reference/block-kit/blocks
- Block Kit Builder: https://app.slack.com/block-kit-builder
