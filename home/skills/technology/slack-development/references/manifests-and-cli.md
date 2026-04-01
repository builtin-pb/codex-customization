# App Manifests And Slack CLI

Use this reference when the task starts before application code exists or when scopes/features need to be reasoned about first.

## Prefer manifests first

- Use an app manifest to define scopes, event subscriptions, slash commands, interactivity, workflow features, and app metadata in one place.
- Prefer manifest-driven setup over click-heavy manual configuration when the app needs to be repeatable across dev, staging, and production.
- Keep scopes minimal at first. Add scopes only when a concrete feature requires them.

## When Slack CLI matters

- Use Slack CLI for app bootstrap, local install flows, and manifest-driven lifecycle work.
- Prefer it for new Slack platform work unless the user is already anchored to older manual setup flows.
- If the user already has an existing app configured manually, avoid forcing a manifest migration unless it directly helps the requested task.

## Practical guidance

- Decide the app's delivery model first: internal only, private distribution, or public distribution.
- Choose scopes from the feature list, not from generic examples.
- Enable interactivity only when actions, shortcuts, or modals are needed.
- Subscribe only to events the app will actually process.

## Official sources

- Slack quickstart: https://docs.slack.dev/quickstart/
- App manifests: https://docs.slack.dev/app-manifests/
- Configure apps with manifests: https://docs.slack.dev/app-manifests/configuring-apps-with-app-manifests/
- Slack CLI: https://docs.slack.dev/tools/slack-cli/
- Slack CLI with Bolt frameworks: https://docs.slack.dev/tools/slack-cli/guides/using-slack-cli-with-bolt-frameworks/
