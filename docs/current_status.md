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
- Optional previous-scan comparison with `--previous-scan`, accepting either a previous report directory or direct `scan_result.json` path, and producing concise AI-actionable `changes` for package-manager, lockfile, runtime version guidance, secret-bearing file signal, missing-tool, project-relevant tool verification failure/recovery, preferred-command, command-policy risk classification, and resolved command-policy entry deltas. Missing-tool comparison distinguishes tools that became available from tools that merely stopped being relevant to the current project.
- `agent_context.md` filters command diagnostics to project-relevant tools while detailed diagnostics remain in the machine and environment reports.
- `agent_context.md` includes previous-scan changes in `Notes` only when a comparison was requested, keeping normal scans short.
- `agent_context.md` uses a clean read-only fallback when no package manager signal is detected.
- If `--project` points to a path that is not an existing directory, `agent_context.md` and `command_policy.md` tell agents to verify the path before running project commands and only allow path existence checks.
- Read-only command execution with timeout, duration, stdout, stderr, exit code, and availability capture.
- Missing commands and scanner failures are represented as scan data instead of fatal errors.
- `scan_result.json` records PATH resolution and version availability for Python, pip, uv, pyenv, RubyGems, and Ruby tooling in addition to the project package managers.
- Project-relevant version command failures, such as a resolved `go` executable whose `go version` check fails, now add Ask First guards and suppress related Markdown build/test allowances.
- `agent_context.md` tells agents to verify the selected executable before running project commands when that tool's version check fails, instead of saying to use an unverifiable tool.
- `agent_context.md` also tells agents to verify the selected executable when a project-relevant tool is missing, instead of saying to use a tool that is not on `PATH`.
- Project signal detection for common JavaScript, Python, Swift, Ruby, Go, Rust, CocoaPods, Carthage, Homebrew, and version-manager files.
- Bun projects are detected from both current `bun.lock` and legacy `bun.lockb` lockfiles.
- pnpm workspaces are detected from `pnpm-workspace.yaml` so workspace roots without lockfiles do not fall back to npm guidance.
- Basic package manager inference from lockfiles and project files.
- JavaScript projects with `package.json` but no lockfile now default to npm guidance while still requiring approval for installs.
- `npm-shrinkwrap.json` is treated as an npm lockfile signal, including missing-`npm` guards and lockfile comparison.
- JavaScript projects with a `packageManager` field in `package.json` use that package manager when no lockfile is present.
- JavaScript `packageManager` hints from `package.json` are preserved in `scan_result.json`, and conflicts with lockfiles require approval before dependency installs.
- JavaScript `packageManager` versions from `package.json` are captured in `scan_result.json` and dependency installs require confirmation when the active package-manager version differs or cannot be verified.
- JavaScript package-manager version hints from `.tool-versions`, `mise.toml`, and `.mise.toml` `[tools]` entries for `npm`, `pnpm`, `yarn`, and `bun` are captured with `packageManagerVersionSource`, including TOML table headers with harmless whitespace or trailing comments, so dependency installs require confirmation when the active selected tool differs.
- `agent_context.md` includes the known package-manager version source in `Use`, such as `.tool-versions`, `mise.toml`, `.mise.toml`, or `package.json`, so agents can inspect the right safe metadata before installs.
- Corepack integrity suffixes such as `+sha512...` are omitted from JavaScript package-manager version artifacts so `agent_context.md` stays concise while version checks still compare the command-relevant version.
- Previous-scan comparison reports selected JavaScript package-manager version/source guidance changes, so agents re-check active package-manager versions before dependency installs.
- Previous-scan comparison reports Node/Python/Ruby runtime hint changes, so agents re-check active runtimes before dependency installs or build/test commands.
- `pnpm-workspace.yaml` is treated as a pnpm project signal even when a stale npm/yarn/bun lockfile is present, and dependency installs require confirmation until the conflicting signals are resolved.
- JavaScript Volta pins and `engines.node` hints in `package.json` are captured as safe Node/package-manager version metadata, including common comparator and OR ranges such as `>=20 <22` and `>=18 <19 || >=20 <21`; dependency installs require confirmation when active versions differ or cannot be verified.
- JavaScript `package.json` script names are captured without script bodies, and generated preferred commands only suggest known safe script names such as `test` and `build` when those scripts exist.
- JavaScript dependency mutation commands such as `npm ci`, `npm update`, `pnpm add`, `yarn add`, and `bun add` are explicitly classified as Ask First.
- Ephemeral package execution commands such as `npx`, `npm exec`, `pnpm dlx`, `yarn dlx`, `bunx`, and `uvx` are classified as Ask First because they can fetch or execute packages outside the selected project workflow.
- JavaScript global package installs such as `npm install -g`, `pnpm add -g`, `yarn global add`, and `bun add -g` are classified as Forbidden.
- JavaScript projects ask before running package-manager commands when the selected package manager is available but the Node runtime itself is missing.
- JavaScript preferred commands and generic selected-project build/test allowance are suppressed from Markdown artifacts when Node is missing, so `command_policy.md` does not allow commands blocked by the missing-runtime guard.
- JavaScript projects ask before running the selected package manager when `npm`, `pnpm`, `yarn`, or `bun` is missing, and warn before substituting another package manager.
- JavaScript projects verify the selected package manager when it is resolved on `PATH`; a failing `npm --version`, `pnpm --version`, `yarn --version`, or `bun --version` suppresses related preferred Markdown commands and requires Ask First even without a `package.json` package-manager version pin.
- JavaScript projects include `node --version` failure details in `agent_context.md` when Node is resolved but unverifiable, so agents see why JavaScript commands are Ask First.
- Non-zero version command exits are treated as unverifiable tool versions, recorded in diagnostics, and used to keep dependency-install guards active.
- Runtime mismatch warnings and command-policy guards when `.nvmrc` or `.node-version` differs from the active Node major version, or `.python-version` differs from active Python major/minor.
- `.tool-versions`, `mise.toml`, and `.mise.toml` Node/Python/Ruby runtime hints are captured without reading secret files and feed dependency-install verification guards.
- Ruby version hints from `.ruby-version`, `.tool-versions`, `mise.toml`, or `.mise.toml` add Bundler dependency-install guards when active Ruby differs or cannot be verified.
- Project `.venv` detection that tells agents to prefer `.venv/bin/python` before system `python3`.
- Project `.venv/bin/python` detection requires an executable interpreter path, suppresses broken virtualenv Python recommendations, and asks before Python commands or recreating `.venv` when the directory exists without an executable interpreter.
- Python projects with an executable `.venv/bin/python` keep project-local test guidance even when `python3` is missing from `PATH`, avoiding a contradictory broad missing-`python3` Ask First guard.
- Python command guidance from secondary Python signals such as `requirements-dev.txt`, `Pipfile`, and `Pipfile.lock`.
- Python dependency install aliases such as `pip3 install` and `python3 -m pip install` are classified as Ask First, with global pip installs and `--user` variants forbidden.
- Language-level global install commands such as `gem install`, `go install`, and `cargo install` are classified as Forbidden.
- Python projects ask before running Python commands when `python3` is missing, and matching Python version hints no longer create unnecessary mismatch warnings.
- Python projects that contain both `pyproject.toml` and `requirements*.txt` now ask before dependency installs until the dependency source of truth is clear.
- Python projects that contain both `uv.lock` and `requirements*.txt` now ask before dependency installs until the dependency source of truth is clear.
- Python projects with `uv.lock` ask before running `uv` commands when `uv` itself is missing, even if Python or pip is available as a possible fallback.
- Python/uv projects with an executable `.venv/bin/python` keep that concrete project-local test command in Markdown guidance even when `uv` is missing, while broader build commands remain suppressed until the selected tool is available.
- uv projects ask before running `uv` commands when `uv --version` fails despite `uv` being resolved on PATH, and generated Markdown suppresses `uv run` until the tool can be verified.
- Ruby Bundler command guidance from `Gemfile` and `Gemfile.lock`, including a missing `bundle` guard.
- Bundler projects verify `bundle --version`; if the resolved `bundle` check fails, generated Markdown suppresses `bundle exec` and asks before Bundler commands.
- Homebrew Bundle, CocoaPods, and Carthage projects verify `brew --version`, `pod --version`, or `carthage version`; if the resolved selected tool check fails, generated Markdown suppresses related preferred commands and asks before related commands.
- SwiftPM command guidance from `Package.swift` and `Package.resolved`, including a missing `swift` guard and `swift package update` / `swift package resolve` mutation guards.
- SwiftPM/Xcode project guidance asks before build or test commands when `xcode-select -p` cannot verify the active developer directory, suppresses concrete Markdown build/test recommendations, and surfaces the relevant diagnostic in `agent_context.md`.
- SwiftPM/Xcode Markdown policy suppresses concrete preferred commands and generic selected-project build/test allowance when `xcode-select -p` cannot verify the active developer directory.
- Xcode project/workspace guidance from top-level `.xcodeproj` and `.xcworkspace` bundles, including `xcodebuild -list` as the safe first command, missing or failing `xcodebuild -version` guards, and Ask First guards for scheme-specific build/test/archive and dependency/provisioning mutations.
- `agent_context.md` avoids telling agents to use `xcodebuild` when Xcode tooling is missing or unverifiable; it tells them to verify Xcode tooling first while keeping concrete Xcode commands out of Markdown guidance.
- Go command guidance from `go.mod`, including missing `go` and `go get`/`go mod tidy` guards.
- Rust Cargo command guidance from `Cargo.toml`, including missing `cargo`, failing `cargo --version`, and `cargo add`/`cargo update` guards.
- CocoaPods guidance from `Podfile` and `Podfile.lock`, including missing `pod` and `pod install`/`pod update` mutation guards.
- Carthage guidance from `Cartfile` and `Cartfile.resolved`, including missing `carthage` and `carthage bootstrap`/`carthage update` mutation guards.
- Homebrew Bundle guidance from `Brewfile`, including `brew bundle check` as the safe preferred command plus missing `brew`, `brew bundle` mutation guards, and direct Homebrew maintenance guards such as `brew update`, `brew cleanup`, and `brew autoremove`.
- Secret-bearing env file detection for common variants such as `.env.local`, `.env.development`, `.env.test`, and `.env.production` without reading their values.
- Additional top-level `.env.*` files such as `.env.staging` are detected by filename without reading their values.
- Direnv-style `.envrc`, `.envrc.*`, and `.envrc.example` files are detected by filename without reading their values, and generated artifacts forbid reading `.envrc` values.
- Project-local `.netrc` files are detected by filename without reading credential values, and generated artifacts forbid reading `.netrc` values.
- Package-manager auth config detection for `.npmrc`, `.pnpmrc`, `.yarnrc`, `.yarnrc.yml`, `.pypirc`, `pip.conf`, `.gem/credentials`, `.bundle/config`, `.cargo/credentials.toml`, `.cargo/credentials`, `auth.json`, and `.composer/auth.json` without reading token values, plus filename-only warnings that tell agents exactly which auth config files to avoid opening.
- Common top-level and `.ssh/` SSH private key filenames such as `id_rsa`, `id_dsa`, `id_ecdsa`, and `id_ed25519` are detected by filename without reading their values, and generated artifacts forbid reading SSH private keys.
- `agent_context.md` prioritizes project-relevant secret-reading bans in Avoid when `.env` examples/variants, `.envrc` examples/variants, `.netrc`, SSH private key filenames, or package-manager auth config files such as `.pnpmrc`, `.pypirc`, `.bundle/config`, `.cargo/credentials.toml`, or `.composer/auth.json` are detected.
- Missing preferred tool warnings when project files point to a tool that is not on `PATH`, including SwiftPM-specific guidance when `swift` is unavailable.
- `agent_context.md` and `command_policy.md` suppress concrete preferred commands and generic selected-project test/build allowance from `Use` and `Allowed` when the required executable is missing, leaving executable verification wording plus the missing-tool Ask First guard visible instead.
- Selected package-manager install guards are prioritized so the short `agent_context.md` shows the relevant install command first.
- Multiple JavaScript lockfile warnings that tell agents to ask before dependency installs when package-manager signals conflict.
- Secret-avoidance fixture test proving `.env` and private key contents are not emitted in generated artifacts.
- Command-policy guard that tells agents to ask before modifying lockfiles.
- Command-policy guard that tells agents to ask before project deletion, cleanup, workspace-discard, stash mutation, local ref deletion/reset, history-rewrite, and destructive or broad remote Git commands such as `git clean`, `git reset --hard`, `git checkout --`, `git checkout -f`, `git checkout -B`, `git switch --discard-changes`, `git switch -C`, `git restore`, `git rm`, `git stash`, `git stash push`, `git stash pop`, `git stash apply`, `git stash drop`, `git stash clear`, `git branch -d`, `git branch -D`, `git tag -d`, `git rebase`, `git push -f`, `git push --force`, `git push --force-with-lease`, `git push --delete`, `git push --mirror`, `git push --all`, `git push --tags`, `git push <remote> +<ref>`, `git push <remote> :<ref>`, `rm`, `rm -r`, and `rm -rf`.
- Command-policy guard that forbids destructive file deletion outside the selected project.
- Tests for package manager detection, package.json-only npm guidance, npm/yarn/bun lockfile missing-tool guards, `npm-shrinkwrap.json` npm lockfile guidance, pnpm workspace guidance including stale non-pnpm lockfile conflicts, package script guidance, `packageManager` field/version, `.tool-versions`, `mise.toml`, and `.mise.toml` package-manager version guards including commented TOML `[tools]` headers, and Corepack integrity suffix omission, Volta and `engines.node` Node/package-manager metadata including satisfied comparator and OR ranges, and lockfile-conflict guidance, JavaScript selected-package-manager and Node version-check failure guards, JavaScript dependency mutation guards, ephemeral package execution Ask First guards, JavaScript and language-level global install forbids, missing Node runtime guards, missing tools, missing-tool suppression of concrete Markdown preferred commands, non-zero version command failures, project-relevant version-check failure guards, previous-scan missing-tool availability versus relevance changes, previous-scan project-relevant tool verification failures, previous-scan JavaScript package-manager version guidance changes, previous-scan runtime hint guidance changes, previous-scan secret-bearing file signal deltas, previous-scan policy risk transitions and resolved policy entries, artifact generation, runtime mismatch policy guidance, `.tool-versions`, `mise.toml`, and `.mise.toml` runtime hints, package-manager substitution guidance, conflicting JavaScript lockfiles, lockfile mutation guidance, project deletion/cleanup/workspace-discard/history-rewrite/remote-Git guards, generated Markdown snapshots, no-signal read-only fallback, secret avoidance, arbitrary `.env.*`, `.envrc.*`, `.envrc.example`, `.netrc`, `.pnpmrc`, `.pypirc`, `pip.conf`, `.gem/credentials`, `.bundle/config`, `.cargo/credentials.toml`, `.cargo/credentials`, `auth.json`, `.composer/auth.json`, and top-level or `.ssh/` SSH private key filename detection without value emission, secret-aware `agent_context.md` Avoid guidance, package-manager auth config warnings, common env file warnings, Python missing-tool guards, satisfied Python runtime hints, broken and non-executable `.venv` guards, Python mixed-dependency signal guards, uv/requirements dependency-source guards, uv missing-tool and version-check failure command guards, Bundler missing-tool and version-check failure guards, SwiftPM `Package.resolved`, missing-tool, dependency-mutation, and `xcode-select -p` partial-failure guards, Xcode workspace/project detection plus missing and failing `xcodebuild` guards, Go missing-tool guards, Cargo missing-tool and version-check failure guards, CocoaPods missing-tool, mutation, and version-check failure guards, Carthage missing-tool, mutation, and version-check failure guards, and Brewfile Homebrew Bundle missing-tool, version-check failure, plus direct Homebrew maintenance guards.
- GitHub CI and release artifact workflows.

## Not Yet Implemented

- Homebrew scanner detail beyond command-decision guidance; this should stay narrow and avoid `brew doctor`-style broad diagnostics.
- Detailed pip policy beyond install and mixed-dependency signal guards.
- Additional Node package-manager version metadata beyond `package.json`, Volta pins, `engines.node`, `.tool-versions`, `mise.toml`, and `.mise.toml`.
- Swift/Xcode scanner detail beyond safe first-command guidance; this should stay focused on build/test command selection and safety.
- Broader scan comparison beyond the initial AI-actionable deltas; avoid adding this unless it changes agent behavior.
- GUI, MCP server, and redaction modes.

## Next Useful Improvements

- Add fixture projects that cover remaining non-JavaScript missing-tool cases where the generated policy changes.
- Add focused Python and Node scanner summaries only where they change AI command choices.
- Improve previous-scan comparison only where it changes command choice, approval requirements, or refusal decisions.
