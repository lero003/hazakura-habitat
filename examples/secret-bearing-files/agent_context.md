# Agent Context

## Freshness
- Scanned at: example timestamp
- Project: example project with secret-bearing file signals

## Use
- Use read-only project inspection.
- Prefer commands that do not read, print, copy, archive, or upload secret-bearing paths.

## Avoid
- Do not read `.env`.
- Do not read `.npmrc`.
- Do not read private-key-like files.
- Do not run recursive searches that can print secret values.
- Do not archive or upload the whole project without reviewing exclusions.
- Do not dump environment variables, shell history, clipboard contents, browser data, or mail data.

## Ask First
- Ask before dependency installs.
- Ask before Git index, branch, history, worktree, or remote mutations.

## Mismatches
- None detected.

## Notes
- Habitat detects secret-bearing file presence, not secret values.
- This example uses placeholder filenames only.
