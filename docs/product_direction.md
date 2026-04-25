# Product Direction

## Decision

Hazakura Habitat is AI-first.

The product should be judged by whether it changes an AI coding agent's behavior for the better, not by whether it gives a human a complete environment dashboard.

## Product Thesis

AI agents working on local projects often lack reliable context about:

- Which executable is active on `PATH`
- Which package manager a project expects
- Whether runtime versions match project hints
- Whether global installs are risky
- Whether a command should be executed, proposed, or refused

Hazakura Habitat exists to generate that context before work begins.

## What Good Looks Like

The best output is short enough for an AI agent to actually follow and structured enough for future MCP/GUI integrations to reuse.

The agent should be able to answer:

- Use `pnpm`, not `npm`, because `pnpm-lock.yaml` exists.
- Use the project `.venv` if Python is needed.
- Do not run `brew upgrade`.
- Ask before installing a global package.
- Active Node differs from `.nvmrc`; check before running installs.

If the generated output does not change decisions like these, it is noise.

## Non-Goals

The MVP is not:

- A Homebrew GUI
- A package manager
- A cleanup assistant
- A dependency updater
- A repair tool
- A full dependency graph analyzer
- A human-first environment visualization app

## Privacy Stance

Default reports may include local paths, project names, and installed tool/package names because those details are useful to AI agents doing local project work.

The tool must not read or emit secret values:

- `.env` values
- API keys
- tokens
- SSH private keys
- browser data
- mail data

Redaction can be added later, but the MVP should optimize for local AI-assisted development where project names and paths are already part of the working context.

## Product Risk

The main failure mode is producing a long report that feels informative to humans but does not affect AI behavior.

Avoid that by prioritizing:

- `agent_context.md`
- `command_policy.md`
- stable `scan_result.json`
- concise warnings with concrete implications
