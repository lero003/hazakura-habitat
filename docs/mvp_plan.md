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

## Roadmap Structure

The roadmap is not a linear scanner-completion checklist.

Hazakura Habitat is centered on AI-facing outputs. System, project, and tool scanners are inputs that improve those outputs only when they change an AI coding agent's next command decision.

Current phase:

> CLI MVP is usable. The project is now in Agent Safety Hardening.
>
> The goal is not to add broad environment coverage.
> The goal is to make AI-facing outputs short, conservative, stable, and useful enough that an AI coding agent avoids wrong or unsafe commands before touching a repository.

## MVP Core

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

### M5: AI-Facing Outputs

Status: MVP usable, continuously refined.

Generate:

- `scan_result.json`
- `agent_context.md`
- `command_policy.md`
- `environment_report.md`

Acceptance test:

An AI agent reading only `agent_context.md` and `command_policy.md` should know what to use, what to avoid, and what to ask before doing.

These outputs are the core product surface. They should keep improving as M2, M3, M4, and M6 add better input signals and safer edge-case handling.

## MVP Inputs

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

Read only safe metadata such as `package.json` package manager hints, Volta Node/package-manager pins, `engines.node` hints including common comparator and OR ranges, and script names, plus Node/Python version hints from `.tool-versions`. Preserve `package.json` package manager hints in scan data even when lockfiles select a different package manager, so agents can ask before installs. Never read `.env` / `.envrc` values or package-manager auth token values.

### M4: Focused Tool Scanners

Status: partially implemented.

Collect enough information to guide AI behavior.

Do not broaden scanners into comprehensive local environment diagnostics. Scanner scope should stay limited to data that changes command choice, approval requirements, or refusal decisions.

Homebrew:

- whether `brew` is available
- whether `Brewfile` exists
- whether `brew bundle check` is a safe preferred command
- whether `brew bundle`, install, update, cleanup, dump, or upgrade commands require approval or refusal
- avoid `brew doctor`-style broad diagnostics unless a narrow warning directly changes AI command behavior

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
- avoid broad Xcode diagnostics unless they affect build/test command selection or safety

## Agent Safety Hardening

### M6: Agent Safety Hardening

Status: in progress.

Focus:

- missing tool handling
- partial scanner failure handling
- secret avoidance
- conservative command policy
- fixture-based regression tests
- Markdown snapshot stability
- example reports from synthetic fixtures
- known limitations documented in `environment_report.md`

The goal is to prevent dangerous, mistaken, or wasteful commands before an agent touches a repository.

## Near-Term Candidates

### Lightweight Scan Comparison

Status: initial implementation complete.

`habitat-scan scan --previous-scan /path/to/habitat-report` compares the current scan with a previous machine artifact and records concise `changes` in `scan_result.json`. The option accepts either a previous report directory or a direct `scan_result.json` path. `agent_context.md` includes those changes in `Notes` only when they exist.

Initial scope should be limited to AI-actionable deltas:

- package manager selection changed since the previous scan
- lockfiles appeared or disappeared
- missing tools appeared, were resolved, or stopped being relevant to the current project
- command policy risk classification changed or a previous policy entry is no longer highlighted

Avoid broad environment diffs. The comparison should answer: what changed that should alter the agent's next action?

## Deferred

- SwiftUI app
- MCP server
- Redaction modes
- dependency cleanup candidates
- environment change logs
- package install/update/delete helpers
