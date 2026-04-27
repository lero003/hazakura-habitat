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
- Optional previous-scan comparison with `--previous-scan`, accepting either a previous report directory or direct `scan_result.json` path, and producing concise AI-actionable `changes` for package-manager, lockfile, missing-tool, project-relevant tool verification failure/recovery, command-policy risk classification, and resolved command-policy entry deltas. Missing-tool comparison distinguishes tools that became available from tools that merely stopped being relevant to the current project.
- `agent_context.md` filters command diagnostics to project-relevant tools while detailed diagnostics remain in the machine and environment reports.
- `agent_context.md` includes previous-scan changes in `Notes` only when a comparison was requested, keeping normal scans short.
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
- Ephemeral package execution commands such as `npx`, `npm exec`, `pnpm dlx`, `yarn dlx`, `bunx`, and `uvx` are classified as Ask First because they can fetch or execute packages outside the selected project workflow.
- JavaScript global package installs such as `npm install -g`, `pnpm add -g`, `yarn global add`, and `bun add -g` are classified as Forbidden.
- JavaScript projects ask before running package-manager commands when the selected package manager is available but the Node runtime itself is missing.
- JavaScript preferred commands and generic selected-project build/test allowance are suppressed from Markdown artifacts when Node is missing, so `command_policy.md` does not allow commands blocked by the missing-runtime guard.
- JavaScript projects ask before running the selected package manager when `npm`, `pnpm`, `yarn`, or `bun` is missing, and warn before substituting another package manager.
- Non-zero version command exits are treated as unverifiable tool versions, recorded in diagnostics, and used to keep dependency-install guards active.
- Runtime mismatch warnings and command-policy guards when `.nvmrc` or `.node-version` differs from the active Node major version, or `.python-version` differs from active Python major/minor.
- `.tool-versions` Node/Python/Ruby runtime hints are captured without reading secret files and feed dependency-install verification guards.
- Ruby version hints from `.ruby-version` or `.tool-versions` add Bundler dependency-install guards when active Ruby differs or cannot be verified.
- Project `.venv` detection that tells agents to prefer `.venv/bin/python` before system `python3`.
- Project `.venv/bin/python` detection that suppresses broken virtualenv Python recommendations and asks before Python commands or recreating `.venv` when the directory exists without an interpreter.
- Python command guidance from secondary Python signals such as `requirements-dev.txt`, `Pipfile`, and `Pipfile.lock`.
- Python dependency install aliases such as `pip3 install` and `python3 -m pip install` are classified as Ask First, with `--user` variants forbidden.
- Language-level global install commands such as `gem install`, `go install`, and `cargo install` are classified as Forbidden.
- Python projects ask before running Python commands when `python3` is missing, and matching Python version hints no longer create unnecessary mismatch warnings.
- Python projects that contain both `pyproject.toml` and `requirements*.txt` now ask before dependency installs until the dependency source of truth is clear.
- Python projects that contain both `uv.lock` and `requirements*.txt` now ask before dependency installs until the dependency source of truth is clear.
- Python projects with `uv.lock` ask before running `uv` commands when `uv` itself is missing, even if Python or pip is available as a possible fallback.
- Python/uv projects with a detected `.venv/bin/python` keep that concrete project-local test command in Markdown guidance even when `uv` is missing, while broader build commands remain suppressed until the selected tool is available.
- Ruby Bundler command guidance from `Gemfile` and `Gemfile.lock`, including a missing `bundle` guard.
- SwiftPM command guidance from `Package.swift` and `Package.resolved`, including a missing `swift` guard and `swift package update` / `swift package resolve` mutation guards.
- SwiftPM/Xcode project guidance asks before build or test commands when `xcode-select -p` cannot verify the active developer directory, and surfaces the relevant diagnostic in `agent_context.md`.
- SwiftPM/Xcode Markdown policy suppresses generic selected-project build/test allowance when `xcode-select -p` cannot verify the active developer directory.
- Xcode project/workspace guidance from top-level `.xcodeproj` and `.xcworkspace` bundles, including `xcodebuild -list` as the safe first command, missing `xcodebuild` guards, and Ask First guards for scheme-specific build/test/archive and dependency/provisioning mutations.
- Go command guidance from `go.mod`, including missing `go` and `go get`/`go mod tidy` guards.
- Rust Cargo command guidance from `Cargo.toml`, including missing `cargo` and `cargo add`/`cargo update` guards.
- CocoaPods guidance from `Podfile` and `Podfile.lock`, including missing `pod` and `pod install`/`pod update` mutation guards.
- Carthage guidance from `Cartfile` and `Cartfile.resolved`, including missing `carthage` and `carthage bootstrap`/`carthage update` mutation guards.
- Homebrew Bundle guidance from `Brewfile`, including `brew bundle check` as the safe preferred command plus missing `brew`, `brew bundle` mutation guards, and direct Homebrew maintenance guards such as `brew update`, `brew cleanup`, and `brew autoremove`.
- Secret-bearing env file detection for common variants such as `.env.local`, `.env.development`, `.env.test`, and `.env.production` without reading their values.
- Additional top-level `.env.*` files such as `.env.staging` are detected by filename without reading their values.
- Direnv-style `.envrc`, `.envrc.*`, and `.envrc.example` files are detected by filename without reading their values, and generated artifacts forbid reading `.envrc` values.
- Package-manager auth config detection for `.npmrc`, `.pnpmrc`, `.yarnrc`, and `.yarnrc.yml` without reading token values.
- Common top-level SSH private key filenames such as `id_rsa`, `id_dsa`, `id_ecdsa`, and `id_ed25519` are detected by filename without reading their values, and generated artifacts forbid reading SSH private keys.
- `agent_context.md` prioritizes project-relevant secret-reading bans in Avoid when `.env` examples/variants, `.envrc` examples/variants, SSH private key filenames, or package-manager auth config files such as `.pnpmrc` are detected.
- Missing preferred tool warnings when project files point to a tool that is not on `PATH`, including SwiftPM-specific guidance when `swift` is unavailable.
- `agent_context.md` and `command_policy.md` suppress concrete preferred commands and generic selected-project test/build allowance from `Use` and `Allowed` when the required executable is missing, leaving the missing-tool Ask First guard visible instead.
- Selected package-manager install guards are prioritized so the short `agent_context.md` shows the relevant install command first.
- Multiple JavaScript lockfile warnings that tell agents to ask before dependency installs when package-manager signals conflict.
- Secret-avoidance fixture test proving `.env` and private key contents are not emitted in generated artifacts.
- Command-policy guard that tells agents to ask before modifying lockfiles.
- Command-policy guard that tells agents to ask before project deletion, cleanup, and workspace-discard commands such as `git clean`, `git reset --hard`, `git checkout --`, `git restore`, `git rm`, `rm`, `rm -r`, and `rm -rf`.
- Command-policy guard that forbids destructive file deletion outside the selected project.
- Tests for package manager detection, package.json-only npm guidance, npm/yarn/bun lockfile missing-tool guards, pnpm workspace guidance, package script guidance, `packageManager` field/version, Volta and `engines.node` Node/package-manager metadata including satisfied comparator and OR ranges, and lockfile-conflict guidance, JavaScript dependency mutation guards, ephemeral package execution Ask First guards, JavaScript and language-level global install forbids, missing Node runtime guards, missing tools, missing-tool suppression of concrete Markdown preferred commands, non-zero version command failures, previous-scan missing-tool availability versus relevance changes, previous-scan project-relevant tool verification failures, previous-scan policy risk transitions and resolved policy entries, artifact generation, runtime mismatch policy guidance, `.tool-versions` runtime hints, package-manager substitution guidance, conflicting JavaScript lockfiles, lockfile mutation guidance, project deletion/cleanup/workspace-discard guards, generated Markdown snapshots, no-signal read-only fallback, secret avoidance, arbitrary `.env.*`, `.envrc.*`, `.envrc.example`, `.pnpmrc`, and SSH private key filename detection without value emission, secret-aware `agent_context.md` Avoid guidance, package-manager auth config warnings, common env file warnings, Python missing-tool guards, satisfied Python runtime hints, broken `.venv` guards, Python mixed-dependency signal guards, uv/requirements dependency-source guards, uv missing-tool command guards, Bundler missing-tool guards, SwiftPM `Package.resolved`, missing-tool, dependency-mutation, and `xcode-select -p` partial-failure guards, Xcode workspace/project detection and missing `xcodebuild` guards, Go missing-tool guards, Cargo missing-tool guards, CocoaPods missing-tool and mutation guards, Carthage missing-tool and mutation guards, and Brewfile Homebrew Bundle plus direct Homebrew maintenance guards.
- GitHub CI and release artifact workflows.

## Not Yet Implemented

- Homebrew scanner detail beyond command-decision guidance; this should stay narrow and avoid `brew doctor`-style broad diagnostics.
- Detailed pip policy beyond install and mixed-dependency signal guards.
- Additional Node package-manager version metadata beyond `package.json` `packageManager`, Volta pins, and `engines.node`.
- Swift/Xcode scanner detail beyond safe first-command guidance; this should stay focused on build/test command selection and safety.
- Broader scan comparison beyond the initial AI-actionable deltas; avoid adding this unless it changes agent behavior.
- GUI, MCP server, and redaction modes.

## Next Useful Improvements

- Add fixture projects that cover remaining non-JavaScript missing-tool cases where the generated policy changes.
- Add focused Python and Node scanner summaries only where they change AI command choices.
- Improve previous-scan comparison only where it changes command choice, approval requirements, or refusal decisions.
