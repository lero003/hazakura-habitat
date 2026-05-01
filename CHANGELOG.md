# Changelog

## v0.1.0 Developer Preview - 2026-05-01

Initial public developer preview.

### Included

- SwiftPM CLI: `habitat-scan`.
- Read-only project scan command:
  - `habitat-scan scan --project <path> --output <path>`
- AI-facing artifacts:
  - `scan_result.json`
  - `agent_context.md`
  - `command_policy.md`
  - `environment_report.md`
- `schemaVersion` and `generatorVersion` metadata in `scan_result.json`.
- Project signal detection for SwiftPM/Xcode, Node package managers, Python pip/uv, Ruby Bundler, Go, Cargo, CocoaPods, Carthage, Brewfile, and secret-bearing file presence.
- Conservative command policy for preferred commands, Ask First commands, and Forbidden commands.
- Previous-scan comparison for command-changing deltas.
- Secret-value non-emission tests and safety hardening around secret-bearing files, auth config, shell history, clipboard, browser/mail data, cloud/container credentials, and destructive commands.
- Release artifact build with `SHA256SUMS`.
- MIT License.

### Preview Limitations

- macOS-first.
- Advisory only; Habitat does not execute, approve, or block commands.
- JSON fields may evolve during `v0.x`.
- Markdown output is optimized for AI-agent consumption, not stable machine parsing.
- No GUI, MCP server, sandbox, automatic repair, or broad environment inventory.
