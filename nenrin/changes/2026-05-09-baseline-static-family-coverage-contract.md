---
type: nenrin_change
id: baseline-static-family-coverage-contract
date: 2026-05-09
status: observing
impact: unknown
related_files:
  - Tests/HabitatCoreTests/PolicyReasonCatalogTests.swift
  - CHANGELOG.md
  - docs/current_status.md
  - docs/roadmap.md
  - docs/self_use.md
review_after:
  tasks: 3
  days: 7
---

# Change: baseline-static-family-coverage-contract

## Changed

- Added a PolicyReasonCatalogTests contract proving static command-family arrays remain covered by the baseline Ask First and Forbidden catalogs, while selected SwiftPM and secret-bearing broad-search guards stay dynamic.

## Reason

Baseline catalog assembly now centralizes many command families; without a contract, a future family edit could change reason classification but disappear from rendered static policy or incorrectly become static when it should be generated conditionally.

## Expected Behavior

- Future command-family edits update baseline policy assembly deliberately, preserving generated command counts, reason-code mapping, and dynamic guard boundaries.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Future static command-family additions fail tests if they are not rendered through the baseline policy catalog.
- Dynamic selected-workflow or secret-bearing guards stay generated from repository facts instead of becoming unconditional baseline entries.

## Failure Signals

- The contract becomes a duplicate of generated-output tests without catching catalog assembly drift.
- A new dynamic guard is forced into baseline policy just to satisfy the test.

## Result

Unjudged.
