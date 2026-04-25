# Hazakura Habitat

Hazakura Habitat is an AI-first local environment context generator.

It scans a Mac development environment, resolves tool paths, detects project dependency signals, and emits compact artifacts that help an AI coding agent choose safer commands before it touches a project.

The MVP is not a human dashboard. It is a pre-work contract for AI agents.

## Core Bet

AI agents do not need a beautiful inventory of everything installed on a machine. They need a short, current, structured answer to:

- Which tools should I use for this project?
- Which tools or commands should I avoid?
- Are the active runtimes inconsistent with project files?
- Should I execute a command now, ask first, or refuse?

## MVP Outputs

The primary outputs are:

- `scan_result.json`: stable machine-readable scan data
- `agent_context.md`: short AI-facing project/environment context
- `command_policy.md`: allowed, approval-required, and forbidden command guidance

The secondary output is:

- `environment_report.md`: longer audit/debug report for humans and AI when more detail is needed

The MVP does not generate separate `env_changes.md` or `project_dependency_summary.md`; their useful parts are folded into `agent_context.md` and `command_policy.md`.

## Start Here

- [Product Direction](docs/product_direction.md)
- [MVP Plan](docs/mvp_plan.md)
- [Agent Contract](docs/agent_contract.md)
- [Development Loop](docs/development_loop.md)
- [ADR 0001](docs/adr/0001-ai-first-core-cli.md)

## Current Status

The repository now contains an initial SwiftPM implementation of the AI-first CLI:

- `HabitatCore`: scanner and report generation logic
- `habitat-scan`: executable that writes the four MVP artifacts

## Run

```bash
swift build
./.build/debug/habitat-scan scan --project . --output ./habitat-report
```

Generated files:

- `habitat-report/scan_result.json`
- `habitat-report/agent_context.md`
- `habitat-report/command_policy.md`
- `habitat-report/environment_report.md`

## GitHub

This project is intended to be backed by the GitHub repository `lero003/hazakura-habitat`.

- CI runs on pushes to `main` and on pull requests.
- Release artifacts can be downloaded from GitHub Actions or from GitHub Releases.
- The release workflow packages the `habitat-scan` binary today and will also upload any generated `.app` or `.dmg` files once those exist in the repository build flow.

Manual artifact build:

```bash
./scripts/build_release_artifacts.sh
```
