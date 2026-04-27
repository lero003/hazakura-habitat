# ADR 0002: Agent-Safe Secret Handling

## Status

Accepted

## Context

Hazakura Habitat generates local environment context for AI coding agents.

Some project files are useful signals because their presence changes safe agent behavior. Examples include `.env`, `.env.local`, `.envrc`, `.npmrc`, `.pnpmrc`, `.yarnrc`, SSH private key filenames, and package-manager auth config files.

These files can also contain secrets. A report that includes raw secret values would make the AI-facing artifacts unsafe and harder to share between tools.

## Decision

Habitat must not read, collect, or emit secret values.

When secret-bearing files are relevant, Habitat may report:

- file existence
- file category
- risk classification
- command-policy consequences
- agent-safe summary text

Habitat must prefer agent-safe summaries over raw content.

Examples:

- Report that `.env.local` exists.
- Warn agents not to read `.env` values.
- Forbid reading package-manager auth config values.
- Do not emit variable names or token values from secret-bearing files.

Redaction modes are deferred. The baseline safety model is not "collect then redact"; it is "do not collect secret values."

## Consequences

Positive:

- AI-facing artifacts remain safer by default.
- Future MCP and GUI layers can rely on the same non-secret scan data.
- Tests can assert absence of known secret markers in all generated artifacts.

Tradeoffs:

- Habitat cannot explain secret-file contents.
- Some human debugging workflows are intentionally out of scope.
- If a future feature needs deeper inspection, it must introduce a separate ADR and explicit user approval model.
