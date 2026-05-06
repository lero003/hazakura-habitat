---
type: nenrin_change
id: baseline-policy-list-assembly
date: 2026-05-06
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/PolicyReasonCatalog.swift
  - Sources/HabitatCore/Scanner.swift
  - Tests/HabitatCoreTests/PolicyReasonCatalogTests.swift
  - docs/current_status.md
  - docs/roadmap.md
  - docs/self_use.md
review_after:
  tasks: 3
  days: 7
---

# Change: baseline-policy-list-assembly

## Changed

- Moved the static baseline Ask First and Forbidden command-list assembly into `PolicyReasonCatalog`.
- Left project-specific dynamic guards in `Scanner`.
- Added catalog test coverage for the new baseline list ownership.

## Reason

Scanner was still rebuilding the broad curated policy lists inline even after many individual command families moved into the catalog. Keeping the baseline lists in the catalog reduces drift between command generation, reason classification, and future command-family edits while preserving generated output behavior.

## Expected Behavior

- Generated command counts, ordering, Markdown, and `scan_result.json` stay stable.
- Future broad policy-list edits start in `PolicyReasonCatalog` instead of scanner assembly code.
- Scanner remains focused on current project facts and dynamic guards.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later command-family edits do not need to touch scanner baseline list assembly.
- Self-scan keeps the same command counts and short-context guidance.

## Failure Signals

- Future baseline command additions bypass `PolicyReasonCatalog`.
- Generated policy count or ordering changes during a maintainability-only slice.

## Result

Unjudged.
