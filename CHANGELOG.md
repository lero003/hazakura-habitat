# Changelog

## v0.2.0 Developer Preview - 2026-05-02

Agent Reading Contract release.

### Added

- Added report-relative artifact path metadata to `scan_result.json` so agents and tools can resolve generated Markdown files from a report directory.
- Added generated artifact read-role, read-trigger, read-order, entry-section, entry-line, section-heading line, line-count, character-count, and line-limit metadata for `agent_context.md`, `command_policy.md`, and `environment_report.md`.
- Added command policy reason metadata, command counts, and Review First command metadata so agents can inspect approval reasons without parsing all Markdown.
- Added a bundled `skills/hazakura-habitat` entrypoint for AI agents to run Habitat as a preflight before substantial work.

### Changed

- Stabilized `agent_context.md` around the fixed `Use`, `Prefer`, `Ask First`, `Do Not`, and `Notes` structure.
- Kept `agent_context.md` focused on short command-changing guidance with a 120-line hard budget and overflow guidance that points to the full policy or audit report.
- Reworked `command_policy.md` with a compact `Policy Index`, a high-priority `Review First` section, reason codes, and a reason-code legend before long command lists.
- Kept generated policy advisory-only: Habitat still does not execute, approve, block, sandbox, or enforce commands.
- Clarified that `scan_result.json` remains preview metadata in the `v0.x` series; its purpose is stable, but individual fields may change before `v1.0`.

### Verified

- Local `swift test` passed with 182 tests.
- Self-scan output kept `agent_context.md` under the 120-line limit with no warnings during release preparation.

## v0.1.1 Developer Preview - 2026-05-01

Post-release expectation-setting patch.

### Changed

- Clarified advisory-only language in generated `command_policy.md`.
- Updated README first-time user flow, release install steps, requirements, and exit-code notes.
- Added representative examples for SwiftPM, Node/pnpm lockfile conflict, Python uv missing-tool, and secret-bearing file scenarios.
- Added `CONTRIBUTING.md` and GitHub issue templates.
- Fixed public-preview time-axis wording in docs after the repository became public.

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
