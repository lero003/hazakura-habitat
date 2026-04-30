# Product Direction

## Decision

Hazakura Habitat is AI-first.

The product should be judged by whether it changes an AI coding agent's behavior for the better, not by whether it gives a human a complete environment dashboard.

## Open Source Intent

Hazakura Habitat is not only an app implementation. It is also an argument for a development pattern:

> AI coding agents should receive short, project-derived, conservative command context before they act.

If other tools copy this idea, reuse parts of the mechanism, or build better versions of the same concept, that is a good outcome. The project should be useful as a working CLI, but it should also make the surrounding ecosystem better by making AI-first development more legible and more cautious.

The goal is not to own the category. The goal is to help the idea spread.

## Product Thesis

AI agents working on local projects often lack reliable context about:

- Which executable is active on `PATH`
- Which package manager a project expects
- Whether runtime versions match project hints
- Whether global installs are risky
- Whether a command should be executed, proposed, or refused

Hazakura Habitat exists to generate that context before work begins.

## Product Principles

1. Command decisions over environment inventory.
2. Project-local signals over global machine state.
3. Conservative guidance over automatic mutation.
4. Secret presence over secret contents.
5. Short agent context over exhaustive reports.

Every proposed feature should pass this question:

> Will this signal change the AI agent's next command choice?

If not, defer it.

The public roadmap should strengthen the reliability of this decision context before it expands the product surface. Prefer output quality, behavior evaluation, and policy maintainability over new integrations or broad ecosystem coverage.

## Positioning

Hazakura Habitat should sit before AI coding agents, not replace them.

It is not an agent, sandbox, permission system, or runtime security monitor. It is an agent-neutral context layer that gives tools such as Codex CLI, Claude Code, OpenCode, Cline, Goose, and sandboxed development environments better project-specific command context before work starts.

See `docs/positioning.md` for the current positioning note.

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

The tool must not read, collect, or emit secret values:

- `.env` values
- `.envrc` values
- API keys
- tokens
- SSH private keys
- browser data
- mail data

If a secret-bearing file is relevant, Habitat should report existence, type, and command risk, not raw content. Prefer agent-safe summaries over raw content.

Redaction modes can be added later, but the baseline product rule is stronger than redaction: do not collect secret values in the first place.

## Product Risk

The main failure mode is producing a long report that feels informative to humans but does not affect AI behavior.

Avoid that by prioritizing:

- `agent_context.md`
- `command_policy.md`
- stable `scan_result.json`
- concise warnings with concrete implications
