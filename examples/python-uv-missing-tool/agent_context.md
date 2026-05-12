# Agent Context

## Use
- Verify `uv` before running uv commands.

## Prefer
- Prefer read-only inspection before mutation.

## Ask First
- Ask before `running uv commands before uv is available`.
- Ask before `uv sync`.
- Ask before `uv add`.
- Ask before `uv remove`.
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
- Project: example Python uv project
- Freshness: regenerate if key project files changed after this timestamp; `scan_result.json` includes observed file mtimes.
- Latest observed file: pyproject.toml modified at example timestamp.
- Read order: this file first; `command_policy.md` before risky commands; `environment_report.md` only for diagnostics.
- Scope: short working context; full approval detail is in `command_policy.md`.
- Warning: Project files prefer uv, but uv was not found on PATH; ask before running uv commands or substituting another package manager.
- uv --version unavailable: env: uv: No such file or directory
