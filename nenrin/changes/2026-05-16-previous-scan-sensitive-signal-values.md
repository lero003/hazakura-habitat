---
type: nenrin_change
id: previous-scan-sensitive-signal-values
date: 2026-05-16
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/ScanComparator.swift
  - Tests/HabitatCoreTests/ProjectSymlinkSafetyTests.swift
  - Tests/HabitatCoreTests/SecretFileDetectionTests.swift
  - docs/agent_contract.md
  - docs/current_status.md
review_after:
  tasks: 3
  days: 7
---

# Change: previous-scan-sensitive-signal-values

## Changed

- Added structured `previousValues` and `currentValues` to previous-scan
  `secret_files` and `project_symlinks` deltas.
- Kept the Markdown summaries filename-only while making the machine-readable
  `changes` output identify added or removed sensitive-file and linked-metadata
  signals.
- Updated the agent contract and current status wording so the structured
  previous-scan boundary includes these safety-adjacent signals.

## Reason

Secret-bearing file and project-symlink deltas directly change the next safe
search, copy, archive, dependency, and metadata-following commands. During
`v0.9` hardening, stale-report consumers should not need to scrape prose to see
which filename-only safety boundary changed.

## Expected Behavior

- Machine consumers can inspect sensitive-signal drift directly from
  `scan_result.json`.
- Agents still treat values as filename-only caution, not permission to read or
  follow the files.
- The change stays scoped to previous-scan comparison and does not widen the
  stable JSON schema promise.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Future stale-report consumers use structured values for sensitive-signal
  deltas instead of parsing summary prose.
- Agents continue to avoid reading secret/auth/private-key contents or following
  symlink targets without review.

## Failure Signals

- Consumers treat filenames in `currentValues` as approval to inspect contents.
- `changes` value arrays are interpreted as a stable full-project inventory
  rather than a bounded previous-scan delta.

## Result

Unjudged.
