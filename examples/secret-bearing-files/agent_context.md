# Agent Context

## Use
- Use read-only project inspection.

## Prefer
- Prefer commands that do not read, print, copy, archive, or upload secret-bearing paths.

## Ask First
- Ask before dependency installs.
- Ask before Git/GitHub workspace, history, branch, or remote mutations; see `command_policy.md`.

## Do Not
- Do not read `.env`.
- Do not read `.npmrc`.
- Do not read private-key-like files.
- Do not run recursive searches that can print secret values.
- Do not archive or upload the whole project without reviewing exclusions.
- Do not dump environment variables, shell history, clipboard contents, browser data, or mail data.

## Notes
- Scanned at: example timestamp
- Project: example project with secret-bearing file signals
- Mismatches: none detected.
- Habitat detects secret-bearing file presence, not secret values.
- This example uses placeholder filenames only.
