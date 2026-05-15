# Agent Context

## Use
- Verify `cargo` before running Cargo commands.

## Prefer
- Prefer read-only inspection before mutation.

## Ask First
- Ask before `running Cargo commands before cargo version check succeeds`.
- Ask before `cargo add`.
- Ask before `cargo update`.
- Ask before `cargo remove`.
- Ask before Git/GitHub commands that mutate workspace/history/branches/remotes or read/change remote metadata; see `command_policy.md`.
- 157 additional non-Git/GitHub Ask First commands or command families in `command_policy.md` (other reason codes: `dependency_resolution_mutation`, `version_manager_mutation`, `dependency_mutation`, more).

## Do Not
- Do not run `sudo`.
- Do not delete files outside the selected project.
- Do not read, compare, restore, check out, open, edit, copy, move, sync, upload, archive, or load private keys.
- Do not read, open, copy, upload, or archive local cloud or container credential files, or print cloud auth tokens.
- Do not dump environment variables.
- Do not read clipboard contents.
- Do not read shell history.
- Do not inspect browser profiles, cookies, history, or local mail data.
- Do not execute remote scripts through `curl` or `wget` piped into a shell.

## Notes
- Scanned at: example timestamp
- Generator: 0.8.0
- Project: example Cargo project
- Freshness: regenerate if key project files changed after this timestamp; compare key files with `scan_result.json` observed file mtimes.
- Latest observed file: Cargo.toml modified at example timestamp (shortcut only; other observed files may become stale later).
- Read order: this file first; `command_policy.md` before risky commands; `environment_report.md` only for diagnostics.
- Scope: short working context; full approval detail is in `command_policy.md`.
- Warning: Project files prefer Cargo, but cargo version could not be verified; ask before running Cargo commands.
- cargo --version failed with exit code 1: cargo: rustup toolchain is not installed
