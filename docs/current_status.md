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
- Node runtime mismatch warning and command-policy guard when `.nvmrc` and active `node --version` differ by major version.
- Missing preferred package-manager warning when project files point to a tool that is not on `PATH`.
- Tests for package manager detection, missing tools, artifact generation, runtime mismatch policy guidance, package-manager substitution guidance, and generated Markdown snapshots.
- GitHub CI and release artifact workflows.

## Not Yet Implemented

- Detailed Homebrew scanner.
- Python `.venv`, pyenv, uv, and pip policy detail.
- Node package manager version checks beyond active Node detection.
- Swift/Xcode scanner detail beyond basic command capture.
- Explicit secret-avoidance fixture tests.
- GUI, MCP server, scan comparison, and redaction modes.

## Next Useful Improvements

- Add fixture projects that cover pnpm, npm, SwiftPM, Python, and missing-tool cases.
- Add explicit secret-avoidance fixture tests.
- Add focused Python and Node scanner summaries only where they change AI command choices.
