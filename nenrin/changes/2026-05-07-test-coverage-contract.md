---
type: nenrin_change
id: test-coverage-contract
date: 2026-05-07
status: observing
impact: unknown
related_files:
  - Tests/HabitatCoreTests/TestCoverageContractTests.swift
  - Tests/HabitatCoreTests
  - docs/current_status.md
  - docs/roadmap.md
  - docs/self_use.md
review_after:
  tasks: 3
  days: 7
---

# Change: test-coverage-contract

## Changed

- Added a Swift Testing contract that scans Habitat test-suite files and fails when scenario functions are missing `@Test`.
- Left scanner behavior, generated Markdown, `scan_result.json`, command ordering, and reason-code behavior unchanged.

## Reason

A previous self-use pass found intended regression functions that were not executable because they lacked Swift Testing annotations. The contract turns that observed coverage risk into a fast local failure before future suite moves silently drop command-decision coverage.

## Expected Behavior

- Future test refactors fail when scenario functions are moved or added without `@Test`.
- Review can focus on real scanner or generated-output behavior instead of manually auditing annotation presence.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Future suite splits preserve executable coverage without ad hoc annotation audits.
- `swift test` catches missing annotations before a scanner-policy regression is assumed covered.

## Failure Signals

- The contract becomes noisy for helper-only files.
- Test helpers start living in scenario-suite files and need a clearer naming or file-boundary rule.

## Result

Unjudged.
