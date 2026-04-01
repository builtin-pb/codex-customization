# Workflows And Custom Steps

Use this reference when the request involves Slack workflows, workflow triggers, or custom workflow steps.

## When workflows are a good fit

- Repeated business processes with clear inputs and outputs
- Automations that should feel native to Slack instead of being hidden behind a command
- Multi-step flows that benefit from Slack's workflow builder and handoff model

## Design guidance

- Decide whether the user needs a workflow, a slash command, or a modal-first app flow before committing to implementation.
- Treat custom workflow steps as a product choice, not just an API detail. They affect hosting, configuration, and distribution options.
- Keep workflow inputs explicit and minimal. Overloaded steps become harder to reuse and maintain.
- Surface public-distribution implications early, but do not enforce them unless the user wants marketplace-compatible design.

## Important constraint to surface

- Apps with workflow steps are not publicly distributable through the Slack Marketplace.

## Official sources

- Workflows overview: https://docs.slack.dev/workflows/
- Workflow steps: https://docs.slack.dev/workflows/workflow-steps/
- Bolt Python custom steps: https://docs.slack.dev/tools/bolt-python/tutorial/custom-steps
- Bolt JS custom steps: https://docs.slack.dev/tools/bolt-js/tutorials/custom-steps/
