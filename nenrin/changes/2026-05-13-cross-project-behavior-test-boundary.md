---
type: nenrin_change
id: cross-project-behavior-test-boundary
date: 2026-05-13
status: observing
impact: unknown
related_files:
  - Tests/HabitatCoreTests/CrossProjectBehaviorEvaluationTests.swift
  - Tests/HabitatCoreTests/BehaviorEvaluationTests.swift
  - docs/current_status.md
  - docs/roadmap.md
review_after:
  tasks: 3
  days: 7
---

# Change: cross-project-behavior-test-boundary

## Changed

- Moved cross-project behavior fixture tests out of the broader behavior evaluation suite and into `CrossProjectBehaviorEvaluationTests.swift`.
- Kept fixture content and generated output behavior unchanged.

## Reason

Cross-project intake is now a repeated Habitat self-use source. Giving those fixture checks a named boundary makes future stale-report, validation-wrapper, device-blocker, and Nenrin-ledger observations easier to review without growing the general behavior suite.

## Expected Behavior

- Agents add future cross-project intake fixture assertions to the dedicated test file.
- Broader `BehaviorEvaluationTests.swift` stays focused on self-use and search behavior evidence.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later cross-project fixture changes land in the dedicated suite.
- The split reduces navigation cost without changing test behavior.

## Failure Signals

- New cross-project fixture checks return to the general behavior suite.
- The boundary encourages broad watched-project work instead of bounded Habitat-side evidence.

## Result

Unjudged.
