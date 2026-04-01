# Slack AI Apps

Use this reference when the user wants an assistant, agent, copilot, or chat-within-Slack experience instead of a classic Slack app flow.

## AI app concerns differ from classic apps

- AI apps may use assistant-specific events and scopes.
- UX decisions include split view, thread context, streaming responses, and feedback loops.
- The app may need Slack-native context retrieval instead of copying large amounts of Slack data into another system.

## Important guidance

- Prefer Slack's assistant-specific primitives when the app is clearly an AI assistant experience.
- Model thread context explicitly. AI app flows often need context persistence beyond a single message event.
- Treat streaming and status updates as UX features, not just backend plumbing.
- Surface plan requirements early: some AI app capabilities depend on workspace plan features.

## Official sources

- Using AI in Apps with Bolt Python: https://docs.slack.dev/tools/bolt-python/concepts/ai-apps
- Using AI in Apps with Bolt JS: https://docs.slack.dev/tools/bolt-js/concepts/ai-apps/
- AI Chatbot tutorial for Bolt Python: https://docs.slack.dev/tools/bolt-python/tutorial/ai-chatbot/
- Split view surface: https://docs.slack.dev/surfaces/split-view
- Slack data access for AI apps: https://docs.slack.dev/apis/web-api/using-data-access-api
- Agents & AI app changelog context: https://docs.slack.dev/changelog/2024/09/16/apps
