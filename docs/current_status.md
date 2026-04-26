# Current Status

## Implemented

- SwiftPM package with `HabitatCore` and `habitat-scan`.
- `habitat-scan scan --project /path/to/project --output ./habitat-report`.
- Stable MVP artifact generation:
  - `scan_result.json`
  - `agent_context.md`
  - `command_policy.md`
  - `environment_report.md`
- Read-only command execution with timeout, duration, stdout, stderr, exit code, and availability capture.
- Missing commands and scanner failures are represented as scan data instead of fatal errors.
- Project signal detection for common JavaScript, Python, Swift, Ruby, Go, Rust, Homebrew, and version-manager files.
- Basic package manager inference from lockfiles and project files.
- JavaScript projects with `package.json` but no lockfile now default to npm run/build guidance while still requiring approval for installs.
- JavaScript projects with a `packageManager` field in `package.json` use that package manager when no lockfile is present.
- Runtime mismatch warnings and command-policy guards when `.nvmrc` or `.node-version` differs from the active Node major version, or `.python-version` differs from active Python major/minor.
- Project `.venv` detection that tells agents to prefer `.venv/bin/python` before system `python3`.
- Python command guidance from secondary Python signals such as `requirements-dev.txt`, `Pipfile`, and `Pipfile.lock`.
- Secret-bearing env file detection for common variants such as `.env.local`, `.env.development`, `.env.test`, and `.env.production` without reading their values.
- Missing preferred tool warnings when project files point to a tool that is not on `PATH`, including SwiftPM-specific guidance when `swift` is unavailable.
- Multiple JavaScript lockfile warnings that tell agents to ask before dependency installs when package-manager signals conflict.
- Secret-avoidance fixture test proving `.env` and private key contents are not emitted in generated artifacts.
- Command-policy guard that tells agents to ask before modifying lockfiles.
- Tests for package manager detection, package.json-only npm guidance, `packageManager` field guidance, missing tools, artifact generation, runtime mismatch policy guidance, package-manager substitution guidance, conflicting JavaScript lockfiles, lockfile mutation guidance, generated Markdown snapshots, secret avoidance, common env file warnings, uv missing-tool fallback guards, and SwiftPM missing-tool guards.
- GitHub CI and release artifact workflows.

## Not Yet Implemented

- Detailed Homebrew scanner.
- Detailed pyenv and pip policy detail.
- Node package manager version checks beyond active Node detection.
- Swift/Xcode scanner detail beyond basic command capture.
- GUI, MCP server, scan comparison, and redaction modes.

## Next Useful Improvements

- Add fixture projects that cover npm and remaining missing-tool cases.
- Add focused Python and Node scanner summaries only where they change AI command choices.
