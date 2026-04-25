# ADR 0001: AI-First Core and CLI

## Status

Accepted

## Context

The original concept included a human-facing macOS app, detailed Markdown reports, environment change logs, and project summaries.

After review, the strongest product direction is not broad human visibility. It is helping an AI coding agent act safely before modifying a local project.

Long reports and many generated files can become noise. The product should instead produce a small set of artifacts that directly affect agent behavior.

## Decision

Build Hazakura Habitat as an AI-first SwiftPM project with:

- reusable `HabitatCore`
- CLI executable `habitat-scan`
- primary machine artifact `scan_result.json`
- primary AI prompt artifact `agent_context.md`
- primary command safety artifact `command_policy.md`
- secondary detailed artifact `environment_report.md`

Use SwiftPM from the start.

Defer:

- SwiftUI app
- MCP server
- separate `env_changes.md`
- separate `project_dependency_summary.md`
- redaction modes
- cleanup/update/install features

## Consequences

Positive:

- The MVP is smaller and sharper.
- AI usefulness becomes the main acceptance criterion.
- Future MCP and GUI layers can reuse the same core.
- The product avoids becoming a generic environment dashboard.

Tradeoffs:

- Human-facing polish is delayed.
- Some broad inventory features are deferred.
- Report design must stay disciplined and concise.

