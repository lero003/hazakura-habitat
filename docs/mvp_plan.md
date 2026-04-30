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
- `npm-shrinkwrap.json`
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
- `*.xcodeproj`
- `*.xcworkspace`
- `Podfile`
- `Podfile.lock`
- `Cartfile`
- `Cartfile.resolved`
- `Brewfile`
- `mise.toml`
- `.mise.toml`
- `.tool-versions`
- `.python-version`
- `.ruby-version`
- `.node-version`
- `.nvmrc`
- `.npmrc`
- `.pnpmrc`
- `.yarnrc`
- `.yarnrc.yml`
- `.pypirc`
- `pip.conf`
- `.gem/credentials`
- `.bundle/config`
- `.cargo/credentials.toml`
- `.cargo/credentials`
- `auth.json`
- `.composer/auth.json`
- `.env.example`
- `.envrc`
- `.envrc.local`
- `.envrc.example`
- `.netrc`
- `id_rsa`
- `id_dsa`
- `id_ecdsa`
- `id_ed25519`
- `.ssh/id_rsa`
- `.ssh/id_dsa`
- `.ssh/id_ecdsa`
- `.ssh/id_ed25519`
- `README.md`

Read only safe metadata such as `package.json` package manager hints, Volta Node/package-manager pins, `engines.node` hints including common comparator and OR ranges, and script names, plus Node/Python/Ruby/package-manager version hints from `.tool-versions`, `mise.toml`, and `.mise.toml` `[tools]`. Preserve `package.json` package manager hints in scan data even when lockfiles or workspace files select a different package manager, so agents can ask before installs. Treat `pnpm-workspace.yaml` as a pnpm project signal even when stale npm/yarn/bun lockfiles are present, and require approval before dependency installs when those signals conflict. Omit Corepack integrity suffixes such as `+sha512...` from package-manager version guidance because they do not change the agent's command choice. Never read `.env` / `.envrc` values, `.netrc` values, SSH private key values, or package-manager auth token values from files such as `.npmrc`, `.pnpmrc`, `.yarnrc.yml`, `.pypirc`, `pip.conf`, `.gem/credentials`, `.bundle/config`, `.cargo/credentials.toml`, `.cargo/credentials`, `auth.json`, or `.composer/auth.json`.

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
- project `.venv` presence and executable `.venv/bin/python` availability
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
- `xcode-select -p` partial-failure guard that suppresses concrete SwiftPM/Xcode Markdown build and test recommendations
- `xcode-select -p` empty-output guard that treats the active developer directory as unverifiable
- `.xcodeproj` / `.xcworkspace` signals with `xcodebuild -list` as the safe first command
- ask before scheme-specific `xcodebuild` build, test, or archive commands until the scheme is selected
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

Automation guidance:

- Work in one-hour, artifact-centered slices.
- It is acceptable for one cycle to touch scanner logic, generated Markdown, fixtures, snapshots, and docs when they all protect the same AI decision.
- Prefer one finished safety improvement over several unrelated small edits.
- Do not expand into broad environment diagnostics unless the added data changes command choice, approval requirements, or refusal decisions.
- When the improvement cannot be finished in one hour, leave the repo with passing focused tests and a clear next artifact boundary.

Project-relevant version command failures should affect command policy, not only diagnostics. When a selected project tool is missing from `PATH`, or is present but its version check fails, times out, or returns empty output, `scan_result.json` should keep related build/test commands out of `policy.preferredCommands` and require Ask First until the tool can be verified.

JavaScript projects apply this partial-failure rule to Node and the selected package manager even when `package.json` does not pin a package-manager version. Missing Node, a missing selected package manager, or a resolved but failing `npm --version`, `pnpm --version`, `yarn --version`, or `bun --version` should keep related preferred commands out of `policy.preferredCommands` until the tool can be verified.

Bundler projects apply the same partial-failure rule to `bundle --version`: a missing or resolved but failing `bundle` should keep `bundle exec` out of `policy.preferredCommands` until the tool can be verified.

uv projects apply the same partial-failure rule to `uv --version`: a missing or resolved but failing `uv` should keep `uv run` out of `policy.preferredCommands` until the tool can be verified. A project-local `.venv/bin/python` command may remain when that executable is detected.

Homebrew Bundle, CocoaPods, and Carthage projects apply the same partial-failure rule to their selected tool checks: missing or resolved but failing `brew --version`, `pod --version`, or `carthage version` should keep related preferred commands out of `policy.preferredCommands` until the tool can be verified.

Xcode projects apply the same partial-failure rule to `xcodebuild -version` and `xcode-select -p`: missing or unverifiable Xcode tooling should keep `xcodebuild -list` out of `policy.preferredCommands` until the tool can be verified.

## Near-Term Candidates

### Lightweight Scan Comparison

Status: initial implementation complete.

`habitat-scan scan --previous-scan /path/to/habitat-report` compares the current scan with a previous machine artifact and records concise `changes` in `scan_result.json`. The option accepts either a previous report directory or a direct `scan_result.json` path. `agent_context.md` includes those changes in `Notes` only when they exist.

Initial scope should be limited to AI-actionable deltas:

- package manager selection changed since the previous scan
- selected JavaScript package-manager version guidance changed while the package manager stayed the same
- Node/Python/Ruby runtime version guidance changed since the previous scan
- lockfiles appeared or disappeared
- secret-bearing file signals appeared or disappeared, without reading or emitting values
- missing tools appeared, were resolved, or stopped being relevant to the current project
- project-relevant tool checks started failing or recovered, such as `xcode-select -p` for Swift/Xcode projects
- preferred commands changed while the selected package manager stayed the same, such as `npm run` becoming `npm run test`
- command policy risk classification changed or a previous policy entry is no longer highlighted

Avoid broad environment diffs. The comparison should answer: what changed that should alter the agent's next action?

## Deferred

- SwiftUI app
- MCP server
- Redaction modes
- dependency cleanup candidates
- environment change logs
- package install/update/delete helpers
