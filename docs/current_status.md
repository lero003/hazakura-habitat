# Current Status

## Current Phase

CLI MVP is usable. The project is now in Agent Safety Hardening.

The goal is not broad Mac environment coverage. The goal is to keep AI-facing outputs short, conservative, stable, and useful enough that an AI coding agent avoids wrong or unsafe commands before touching a repository.

## Implemented

- SwiftPM package with `HabitatCore` and `habitat-scan`.
- `habitat-scan scan --project /path/to/project --output ./habitat-report`.
- Stable MVP artifact generation:
  - `scan_result.json`
  - `agent_context.md`
  - `command_policy.md`
  - `environment_report.md`
- `agent_context.md` filters command diagnostics to project-relevant tools while detailed diagnostics remain in the machine and environment reports.
- `agent_context.md` uses a clean read-only fallback when no package manager signal is detected.
- Read-only command execution with timeout, duration, stdout, stderr, exit code, and availability capture.
- Missing commands and scanner failures are represented as scan data instead of fatal errors.
- `scan_result.json` records PATH resolution and version availability for Python, pip, uv, pyenv, RubyGems, and Ruby tooling in addition to the project package managers.
- Project signal detection for common JavaScript, Python, Swift, Ruby, Go, Rust, CocoaPods, Carthage, Homebrew, and version-manager files.
- Bun projects are detected from both current `bun.lock` and legacy `bun.lockb` lockfiles.
- pnpm workspaces are detected from `pnpm-workspace.yaml` so workspace roots without lockfiles do not fall back to npm guidance.
- Basic package manager inference from lockfiles and project files.
- JavaScript projects with `package.json` but no lockfile now default to npm guidance while still requiring approval for installs.
- JavaScript projects with a `packageManager` field in `package.json` use that package manager when no lockfile is present.
- JavaScript `packageManager` hints from `package.json` are preserved in `scan_result.json`, and conflicts with lockfiles require approval before dependency installs.
- JavaScript `packageManager` versions from `package.json` are captured in `scan_result.json` and dependency installs require confirmation when the active package-manager version differs or cannot be verified.
- JavaScript Volta pins and `engines.node` hints in `package.json` are captured as safe Node/package-manager version metadata, including common comparator and OR ranges such as `>=20 <22` and `>=18 <19 || >=20 <21`; dependency installs require confirmation when active versions differ or cannot be verified.
- JavaScript `package.json` script names are captured without script bodies, and generated preferred commands only suggest known safe script names such as `test` and `build` when those scripts exist.
- JavaScript dependency mutation commands such as `npm ci`, `npm update`, `pnpm add`, `yarn add`, and `bun add` are explicitly classified as Ask First.
- JavaScript projects ask before running package-manager commands when the selected package manager is available but the Node runtime itself is missing.
- JavaScript projects ask before running the selected package manager when `npm`, `pnpm`, `yarn`, or `bun` is missing, and warn before substituting another package manager.
- Non-zero version command exits are treated as unverifiable tool versions, recorded in diagnostics, and used to keep dependency-install guards active.
- Runtime mismatch warnings and command-policy guards when `.nvmrc` or `.node-version` differs from the active Node major version, or `.python-version` differs from active Python major/minor.
- `.tool-versions` Node/Python runtime hints are captured without reading secret files and feed the same dependency-install verification guards.
- Project `.venv` detection that tells agents to prefer `.venv/bin/python` before system `python3`.
- Python command guidance from secondary Python signals such as `requirements-dev.txt`, `Pipfile`, and `Pipfile.lock`.
- Python dependency install aliases such as `pip3 install` and `python3 -m pip install` are classified as Ask First, with `--user` variants forbidden.
- Python projects that contain both `pyproject.toml` and `requirements*.txt` now ask before dependency installs until the dependency source of truth is clear.
- Python projects that contain both `uv.lock` and `requirements*.txt` now ask before dependency installs until the dependency source of truth is clear.
- Ruby Bundler command guidance from `Gemfile` and `Gemfile.lock`, including a missing `bundle` guard.
- SwiftPM command guidance from `Package.swift` and `Package.resolved`, including a missing `swift` guard and `swift package update` / `swift package resolve` mutation guards.
- Go command guidance from `go.mod`, including missing `go` and `go get`/`go mod tidy` guards.
- Rust Cargo command guidance from `Cargo.toml`, including missing `cargo` and `cargo add`/`cargo update` guards.
- CocoaPods guidance from `Podfile` and `Podfile.lock`, including missing `pod` and `pod install`/`pod update` mutation guards.
- Carthage guidance from `Cartfile` and `Cartfile.resolved`, including missing `carthage` and `carthage bootstrap`/`carthage update` mutation guards.
- Homebrew Bundle guidance from `Brewfile`, including `brew bundle check` as the safe preferred command plus missing `brew` and `brew bundle` mutation guards.
- Secret-bearing env file detection for common variants such as `.env.local`, `.env.development`, `.env.test`, and `.env.production` without reading their values.
- Additional top-level `.env.*` files such as `.env.staging` are detected by filename without reading their values.
- Direnv-style `.envrc` and `.envrc.*` files are detected by filename without reading their values, and generated artifacts forbid reading `.envrc` values.
- Package-manager auth config detection for `.npmrc`, `.yarnrc`, and `.yarnrc.yml` without reading token values.
- `agent_context.md` prioritizes project-relevant secret-reading bans in Avoid when `.env` examples/variants or package-manager auth config files are detected.
- Missing preferred tool warnings when project files point to a tool that is not on `PATH`, including SwiftPM-specific guidance when `swift` is unavailable.
- Selected package-manager install guards are prioritized so the short `agent_context.md` shows the relevant install command first.
- Multiple JavaScript lockfile warnings that tell agents to ask before dependency installs when package-manager signals conflict.
- Secret-avoidance fixture test proving `.env` and private key contents are not emitted in generated artifacts.
- Command-policy guard that tells agents to ask before modifying lockfiles.
- Command-policy guard that forbids destructive file deletion outside the selected project.
- Tests for package manager detection, package.json-only npm guidance, npm lockfile missing-tool guards, pnpm workspace guidance, package script guidance, `packageManager` field/version, Volta and `engines.node` Node/package-manager metadata including satisfied comparator and OR ranges, and lockfile-conflict guidance, JavaScript dependency mutation guards, missing Node runtime guards, missing tools, non-zero version command failures, artifact generation, runtime mismatch policy guidance, `.tool-versions` runtime hints, package-manager substitution guidance, conflicting JavaScript lockfiles, lockfile mutation guidance, generated Markdown snapshots, no-signal read-only fallback, secret avoidance, arbitrary `.env.*` and `.envrc.*` detection without value emission, secret-aware `agent_context.md` Avoid guidance, package-manager auth config warnings, common env file warnings, Python mixed-dependency signal guards, uv/requirements dependency-source guards, uv missing-tool fallback guards, Bundler missing-tool guards, SwiftPM `Package.resolved`, missing-tool, and dependency-mutation guards, Go missing-tool guards, Cargo missing-tool guards, CocoaPods missing-tool and mutation guards, Carthage missing-tool and mutation guards, and Brewfile Homebrew Bundle guards.
- GitHub CI and release artifact workflows.

## Not Yet Implemented

- Homebrew scanner detail beyond command-decision guidance; this should stay narrow and avoid `brew doctor`-style broad diagnostics.
- Detailed pip policy beyond install and mixed-dependency signal guards.
- Additional Node package-manager version metadata beyond `package.json` `packageManager`, Volta pins, and `engines.node`.
- Swift/Xcode scanner detail beyond basic command capture; this should focus on build/test command selection and safety.
- Lightweight scan comparison for AI-actionable deltas such as package manager changes, lockfile changes, missing-tool changes, and command-policy risk changes.
- GUI, MCP server, and redaction modes.

## Next Useful Improvements

- Add fixture projects that cover remaining missing-tool cases.
- Add focused Python and Node scanner summaries only where they change AI command choices.
- Add lightweight scan comparison only if it can produce concise, agent-actionable changes.
