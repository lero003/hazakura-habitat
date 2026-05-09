---
type: nenrin_change
id: secret-search-shell-quoting
date: 2026-05-09
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/ReportWriter.swift
  - Tests/HabitatCoreTests/SecretFilePolicyTests.swift
  - CHANGELOG.md
  - docs/current_status.md
  - docs/roadmap.md
  - docs/self_use.md
review_after:
  tasks: 3
  days: 7
---

# Change: secret-search-shell-quoting

## Changed

- Shell-quoted detected secret-bearing paths before rendering `rg --glob` and `git grep` pathspec exclusion examples.
- Added a `SecretFilePolicyTests` contract for apostrophe-bearing detected paths.

## Reason

Secret-bearing search guidance is command-changing: agents may copy the generated exclusion shape directly. If a detected path contains an apostrophe, the generated single-quoted command example must remain pasteable instead of breaking shell syntax or dropping the exclusion.

## Expected Behavior

- Agents can follow generated broad-search examples even when secret-bearing filenames contain apostrophes.
- Existing `.env` / `.npmrc` / private-key guidance remains unchanged for ordinary paths.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later secret-bearing search work keeps generated examples shell-safe.
- Agents still use targeted non-secret reads or exclusion-aware broad search rather than refusing all inspection.

## Failure Signals

- Search guidance becomes too renderer-specific to test clearly.
- The shell-quoted examples become noisy enough to confuse ordinary secret-bearing cases.

## Result

Unjudged.
