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
- Runtime mismatch warnings and command-policy guards when `.nvmrc` or `.node-version` differs from the active Node major version, or `.python-version` differs from active Python major/minor.
- Project `.venv` detection that tells agents to prefer `.venv/bin/python` before system `python3`.
- Missing preferred package-manager warning when project files point to a tool that is not on `PATH`.
- Secret-avoidance fixture test proving `.env` and private key contents are not emitted in generated artifacts.
- Command-policy guard that tells agents to ask before modifying lockfiles.
- Tests for package manager detection, missing tools, artifact generation, runtime mismatch policy guidance, package-manager substitution guidance, lockfile mutation guidance, generated Markdown snapshots, secret avoidance, and uv missing-tool fallback guards.
- GitHub CI and release artifact workflows.

## Not Yet Implemented

- Detailed Homebrew scanner.
- Detailed pyenv and pip policy detail.
- Node package manager version checks beyond active Node detection.
- Swift/Xcode scanner detail beyond basic command capture.
- GUI, MCP server, scan comparison, and redaction modes.

## Next Useful Improvements

- Add fixture projects that cover npm, SwiftPM, and missing-tool cases.
- Add focused Python and Node scanner summaries only where they change AI command choices.
