# Agent Context

## Use
- Use SwiftPM (`swift`) because project files point to it.

## Prefer
- Prefer `swift test`.
- Prefer `swift build`.

## Ask First
- Ask before `swift package update`.
- Ask before `swift package resolve`.
- Ask before `modifying lockfiles`.
- Ask before Git/GitHub workspace, history, branch, or remote mutations; see `command_policy.md`.

## Do Not
- Do not run `sudo`.
- Do not delete files outside the selected project.
- Do not dump environment variables.
- Do not read clipboard contents.
- Do not read shell history.
- Do not execute remote scripts through `curl` or `wget` piped into a shell.

## Notes
- Scanned at: example timestamp
- Project: example SwiftPM package
- Read order: this file first; `command_policy.md` before risky commands; `environment_report.md` only for diagnostics.
- Scope: short working context; full approval detail is in `command_policy.md`.
- Mismatches: none detected.
- Scan completed without relevant command diagnostics.
