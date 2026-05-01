# Agent Context

## Freshness
- Scanned at: example timestamp
- Project: example SwiftPM package

## Use
- Use SwiftPM (`swift`) because project files point to it.
- Prefer `swift test`.
- Prefer `swift build`.

## Avoid
- Do not run `sudo`.
- Do not delete files outside the selected project.
- Do not dump environment variables.
- Do not read clipboard contents.
- Do not read shell history.
- Do not execute remote scripts through `curl` or `wget` piped into a shell.

## Ask First
- Ask before `swift package update`.
- Ask before `swift package resolve`.
- Ask before `modifying lockfiles`.
- Ask before Git/GitHub workspace, history, branch, or remote mutations; see `command_policy.md`.

## Mismatches
- None detected.

## Notes
- Scan completed without relevant command diagnostics.
