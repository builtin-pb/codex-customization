# OAuth And Distribution

Use this reference when the app needs installation, token storage, multiple workspaces, or public distribution.

## Design guidance

- Decide early whether the app is internal-only, privately distributed, or intended for public distribution.
- Request the minimum scopes needed for the actual feature set.
- Treat installation storage as production data, not as a temporary demo concern.
- Add distribution constraints to the design discussion early, but only enforce them when the user wants the app to satisfy those constraints.

## Important constraints to surface

- Socket Mode apps are not allowed in the public Slack Marketplace.
- Apps with workflow steps are not publicly distributable through the Slack Marketplace.
- Public distribution raises the quality bar for scopes, OAuth flows, installation persistence, and operational reliability.

## OAuth notes

- Workspace installs are not just login. They affect scopes, token storage, reinstall flows, and upgrade paths.
- Plan for additive scope changes and re-consent when new features require more access.
- Keep secrets, tokens, and signing credentials out of source control and out of example payloads.

## Official sources

- Installing with OAuth: https://docs.slack.dev/authentication/installing-with-oauth
- Node Slack SDK OAuth: https://docs.slack.dev/tools/node-slack-sdk/oauth/
- Verify requests from Slack: https://docs.slack.dev/authentication/verifying-requests-from-slack/
- Workflow steps: https://docs.slack.dev/workflows/workflow-steps/
- Workflows overview: https://docs.slack.dev/workflows/
