---
type: nenrin_change
id: package-manager-review-baseline-contract
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

# Change: package-manager-review-baseline-contract

## Changed

- Added a `PolicyReasonCatalogTests` contract proving selected package-manager Review First routing uses non-duplicated command lists and that non-SwiftPM promoted commands already exist in the baseline Ask First catalog.
- Documented SwiftPM dependency-resolution commands as the explicit selected-workflow exception instead of pretending every Review First route is baseline-only.

## Reason

The scanner promotes selected package-manager mutation commands to the front of Ask First so agents see the most relevant approval boundary before broad catalog entries. Most routes are baseline promotion. SwiftPM dependency-resolution commands are selected-workflow additions, so the useful contract is to keep that exception explicit while preventing other package-manager routes from becoming hidden policy sources.

## Expected Behavior

- Future package-manager routing changes keep non-SwiftPM Review First commands synchronized with the baseline Ask First catalog.
- Agents see package-manager approval commands earlier in `command_policy.md`, with the SwiftPM selected-workflow exception visible in tests and docs.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Future package-manager additions update the baseline catalog and review routing together unless they are an explicit selected-workflow exception.
- Review First output stays explainable as prioritization plus a documented SwiftPM exception.

## Failure Signals

- A new package-manager route quietly injects non-baseline commands without documenting why it must be selected-workflow only.
- The contract blocks a real command-decision improvement instead of exposing a useful catalog boundary.

## Result

Unjudged.
