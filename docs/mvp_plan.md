# MVP Plan

## Implementation Decision

Use SwiftPM for the first implementation.

Rationale:

- The product is macOS-first.
- Swift has direct access to `Process`, Foundation, Codable, and future SwiftUI integration.
- A SwiftPM package can expose both reusable core logic and a CLI executable.
- Starting in Swift avoids a later rewrite from a prototype language into the likely app stack.

## Target Structure

```text
Hazakura Habitat
├─ Package.swift
├─ Sources
│  ├─ HabitatCore
│  └─ habitat-scan
├─ Tests
│  └─ HabitatCoreTests
├─ Fixtures
└─ docs
```

## MVP Command

```bash
habitat-scan scan --project /path/to/project --output ./habitat-report
```

Default output:

```text
habitat-report/
  scan_result.json
  agent_context.md
  command_policy.md
  environment_report.md
```

## Milestones

### M0: Bootstrap

Status: implemented.

- Create SwiftPM package
- Add `HabitatCore` library target
- Add `habitat-scan` executable target
- Add tests and fixtures directories
- Add CLI help/version command

### M1: Command Runner

Status: implemented at MVP depth.

- Implement bounded read-only command execution
- Capture stdout, stderr, exit code, timeout, duration, and availability
- Provide fake command runner for tests
- Treat missing commands and failures as data, not fatal scan errors

### M2: System and Command Resolution

Status: partially implemented.

Collect:

- macOS version
- architecture
- shell
- `PATH`
- Xcode Command Line Tools path
- Swift version
- Git version

Resolve with `which -a`:

- `python`, `python3`, `pip`, `pip3`
- `node`, `npm`, `pnpm`, `yarn`, `bun`
- `ruby`, `gem`
- `go`
- `rustc`, `cargo`
- `swift`, `git`, `brew`
- `pod`
- `carthage`

### M3: Project Detector

Status: partially implemented.

Detect dependency signals:

- `package.json`
- `package-lock.json`
- `pnpm-lock.yaml`
- `pnpm-workspace.yaml`
- `yarn.lock`
- `bun.lock`
- `bun.lockb`
- `pyproject.toml`
- `requirements.txt`
- `requirements-dev.txt`
- `uv.lock`
- `Pipfile`
- `Pipfile.lock`
- `Gemfile`
- `go.mod`
- `Cargo.toml`
- `Package.swift`
- `Package.resolved`
- `Podfile`
- `Podfile.lock`
- `Cartfile`
- `Cartfile.resolved`
- `Brewfile`
- `mise.toml`
- `.tool-versions`
- `.python-version`
- `.node-version`
- `.nvmrc`
- `.npmrc`
- `.yarnrc`
- `.yarnrc.yml`
- `.env.example`
- `.envrc`
- `.envrc.local`
- `README.md`

Read only safe metadata such as `package.json` package manager hints and script names, plus Node/Python version hints from `.tool-versions`. Never read `.env` / `.envrc` values or package-manager auth token values.

### M4: Focused Tool Scanners

Status: not yet implemented beyond basic command/version capture.

Collect enough information to guide AI behavior.

Homebrew:

- prefix
- formula/cask presence
- leaves
- avoid network-dependent or update-like commands in P0

Python:

- active `python3`
- version
- pip availability
- project `.venv` presence
- pyenv/uv presence

Node:

- active `node`
- version
- package manager files
- package manager versions
- avoid expensive global package inventory unless needed for a warning

Swift/Xcode:

- `xcode-select -p`
- `xcodebuild -version`
- `swift --version`
- SwiftPM/Xcode project signals

### M5: AI-Facing Outputs

Status: implemented at MVP depth.

Generate:

- `scan_result.json`
- `agent_context.md`
- `command_policy.md`
- `environment_report.md`

Acceptance test:

An AI agent reading only `agent_context.md` and `command_policy.md` should know what to use, what to avoid, and what to ask before doing.

### M6: Hardening

Status: in progress.

- Fixture tests for missing tools
- Tests for partial scanner failures
- Snapshot tests for Markdown output
- Tests for secret avoidance
- Example reports from synthetic fixtures
- Known limitations documented in `environment_report.md`

## Deferred

- SwiftUI app
- MCP server
- Redaction modes
- dependency cleanup candidates
- scan comparison
- environment change logs
- package install/update/delete helpers
