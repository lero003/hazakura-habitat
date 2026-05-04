# Hazakura Habitat

Hazakura Habitat is a macOS-first SwiftPM CLI for developers using AI coding agents.

Run it before an agent starts work. It generates short, advisory project context that tells the agent which tools to prefer, which commands require approval, and which secret-bearing paths to avoid.

It does not execute, approve, block, or sandbox commands.

Status: `v0.4.0 Developer Preview` - advisory only - no command enforcement - macOS-first.

The MVP is not a human dashboard. It is a pre-work contract for AI agents: a map before the agent walks, not a fence around the agent.

Hazakura Habitat does not make an AI coding agent safe by itself. It only generates advisory context that an agent or user may choose to follow.

## What This Is Not

Hazakura Habitat is not:

- a local environment dashboard
- a package manager inventory
- a security scanner
- a sandbox
- a secret scanner
- an OS-level command enforcement tool

It does not enforce commands. It generates conservative pre-execution context for AI coding agents.

In generated policy, `Forbidden` means "the generated context tells the agent not to run this." It is advisory guidance, not an operating-system-level block.

## Positioning

Hazakura Habitat is not an AI coding agent, sandbox, or runtime security monitor.

It does not execute, approve, or block commands.

Instead, it generates short, conservative, project-derived context before an AI coding agent starts working. The goal is to help agents choose better commands, avoid risky defaults, and ask before mutating dependencies or touching sensitive files.

Habitat is designed to complement tools such as Codex CLI, Claude Code, OpenCode, Cline, Goose, and sandboxed development environments.

## Typical Use

1. Run Habitat before asking an AI coding agent to work on a project.
2. Give the generated `agent_context.md` to the agent.
3. Use `command_policy.md` when the agent needs fuller guidance on allowed, Ask First, and Forbidden commands.
4. Treat all output as advisory context. Habitat does not configure, approve, deny, or block commands for any agent automatically.

## Agent Skill

For AI-first workflows, the preferred entrypoint is the bundled agent skill:

```bash
npx skills add lero003/hazakura-habitat@hazakura-habitat -g
```

The skill teaches an AI coding agent to run Habitat before substantial project work, dependency or lockfile changes, Git/GitHub mutations, and secret-adjacent operations. It also gives the agent a conservative setup path when `habitat-scan` is not installed yet.

The skill lives at [skills/hazakura-habitat](skills/hazakura-habitat).

## Core Bet

AI agents do not need a beautiful inventory of everything installed on a machine. They need a short, current, structured answer to:

- Which tools should I use for this project?
- Which tools or commands should I avoid?
- Are the active runtimes inconsistent with project files?
- Should I execute a command now, ask first, or refuse?

## Product Principles

1. Command decisions over environment inventory.
2. Project-local signals over global machine state.
3. Conservative guidance over automatic mutation.
4. Secret presence over secret contents.
5. Short agent context over exhaustive reports.

Hazakura Habitat is developed around output quality, not feature breadth. After the `v0.3` behavior evaluation cycle, high-confidence scenarios matter more than broad coverage.

The roadmap prioritizes:

1. Policy Finding Foundation
2. Evidence and instruction alignment
3. Agent behavior feedback loop
4. Integration and distribution foundations

The goal is not to inspect everything on the machine. The goal is to generate concise, conservative context that changes an AI coding agent's next command choice.

Habitat is meant to complement `AGENTS.md` and project docs, not duplicate them. Its value is strongest when it surfaces current repository facts, risky command boundaries, or instruction drift that written guidance alone does not prove. If project docs already answer the command question for a low-risk task, skipping Habitat is acceptable.

## Development Model

Hazakura Habitat is an AI-first developer tool.

It is designed for AI coding agents, and it is also developed with AI coding agents. That is intentional: the project treats AI not as an add-on, but as a primary development participant.

The goal is to make AI-led development more legible and more conservative before commands are executed.

## Open Source Intent

Hazakura Habitat is meant to share an idea as much as an implementation.

If the project helps other tools, developers, or agents adopt better pre-execution context, that is success. Forks, reimplementations, and projects that take the underlying ideas further are welcome.

The goal is not to own this category. The goal is to help the AI-first development ecosystem become more legible and more conservative before commands run.

Credit, citations, or special thanks are warmly appreciated when this project or its ideas help your work, but the license only requires preserving the copyright and license notice.

## MVP Outputs

The primary outputs are:

- `scan_result.json`: machine-readable scan data
- `agent_context.md`: short AI-facing project/environment context
- `command_policy.md`: allowed, approval-required, and forbidden command guidance

The secondary output is:

- `environment_report.md`: longer audit/debug report for humans and AI when more detail is needed

The MVP does not generate separate `env_changes.md` or `project_dependency_summary.md`; their useful parts are folded into `agent_context.md` and `command_policy.md`.

In `v0.x`, `scan_result.json` is preview metadata for audit, debug, and tooling use. Its top-level purpose is stable, but individual fields may change before `v1.0`. Agent-facing guidance should start with `agent_context.md`; use `scan_result.json` for generated artifact metadata including report-relative path, agent reading role, read trigger, read order, entry section, entry line, section heading line index, line and character counts, budget status for line-limited outputs, machine-readable policy `reasonCodes`, command counts including Review First size, top-priority `reviewFirstCommandReasons`, and per-command `commandReasons`.

## Privacy and Prompt-Injection Stance

Hazakura Habitat detects the presence of secret-bearing files, not their values. It should not read, collect, or emit `.env` values, package-registry tokens, SSH private keys, local cloud/container credential values, shell history, clipboard contents, browser data, or mail data.

Tests may contain dummy secret-like strings to verify non-emission behavior. They are not real credentials.

Generated AI-facing Markdown should treat project-derived strings as untrusted data. Prefer normalized signals over raw project text, and do not include arbitrary project file contents in `agent_context.md`.

Runtime version hints from `.nvmrc`, `.node-version`, `.python-version`, `.ruby-version`, `.tool-versions`, `mise.toml`, and `.mise.toml` are only emitted when their values are short, version-like strings. Oversized or suspicious values are reported by filename only and cause dependency installs to require verification first. Suspicious package-manager version metadata from `package.json`, `.tool-versions`, `mise.toml`, or `.mise.toml` is reported by field name only, without emitting the value.

## Start Here

- [Product Direction](docs/product_direction.md)
- [MVP Plan](docs/mvp_plan.md)
- [Current Status](docs/current_status.md)
- [Public Readiness](docs/public_readiness.md)
- [Roadmap](docs/roadmap.md)
- [Positioning](docs/positioning.md)
- [Known Limitations](docs/known_limitations.md)
- [Contributing](CONTRIBUTING.md)
- [Agent Contract](docs/agent_contract.md)
- [Evaluation](docs/evaluation.md)
- [Development Loop](docs/development_loop.md)
- [Self-Use Loop](docs/self_use.md)
- [Agent Skill](skills/hazakura-habitat/SKILL.md)
- [GitHub Workflow](docs/github_workflow.md)
- [ADR 0001](docs/adr/0001-ai-first-core-cli.md)
- [ADR 0002](docs/adr/0002-agent-safe-secret-handling.md)

## Current Status

The repository contains the `v0.4.0 Developer Preview` implementation of the AI-first CLI. See [Current Status](docs/current_status.md) for what is implemented and what should come next.

See [Public Readiness](docs/public_readiness.md) for the completed `v0.1.0` publication checklist and scope boundaries.

## Requirements

- macOS 13 or later.
- Swift 6.1 toolchain or a compatible Xcode toolchain.

## Install From Release

Download `habitat-scan-macos.zip`, `habitat-scan`, and `SHA256SUMS` from the latest GitHub Release, keep them in the same directory, then run:

```bash
shasum -c SHA256SUMS
unzip habitat-scan-macos.zip
./dist/habitat-scan scan --project . --output ./habitat-report
```

`SHA256SUMS` is published alongside the generated release assets. Verification is optional, but recommended before running downloaded binaries.

The zip path is the recommended run path. The standalone `habitat-scan` asset is included so `SHA256SUMS` can verify every generated release artifact.

## Run

```bash
swift build
./.build/debug/habitat-scan scan --project . --output ./habitat-report
```

Optional comparison against a previous scan:

```bash
./.build/debug/habitat-scan scan --project . --output ./habitat-report --previous-scan ./old-habitat-report
```

`--previous-scan` accepts either a previous report directory or a direct `scan_result.json` path.

Generated files:

- `habitat-report/scan_result.json`
- `habitat-report/agent_context.md`
- `habitat-report/command_policy.md`
- `habitat-report/environment_report.md`

## Exit Codes

- `0`: scan completed and artifacts were written.
- non-zero: CLI argument error, output write failure, or fatal scan setup error.
- Missing tools are usually represented as scan data, not fatal errors.

## Example Output

See [examples](examples/README.md) for representative output shapes.

## GitHub

This project is backed by `lero003/hazakura-habitat`. See [GitHub Workflow](docs/github_workflow.md) for commit, CI, and artifact release conventions.

Manual artifact build:

```bash
./scripts/build_release_artifacts.sh
```

This writes local artifacts under `dist/`, including `SHA256SUMS` for release verification.

## License

Hazakura Habitat is released under the [MIT License](LICENSE).
