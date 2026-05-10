---
type: nenrin_change
id: no-secret-search-fixture-coverage
date: 2026-05-10
status: observing
impact: unknown
related_files:
  - Tests/HabitatCoreTests/BehaviorEvaluationTests.swift
  - docs/current_status.md
  - docs/roadmap.md
  - docs/self_use.md
review_after:
  tasks: 3
  days: 7
---

# Change: no-secret-search-fixture-coverage

## Changed

- Added executable behavior-evaluation tests for the existing `swiftpm-self-use-009` and `swiftpm-self-use-011` fixtures.
- Pinned the no-secret self-use behavior where ordinary read-only `rg` remains available, while dependency resolution, broad evidence expansion, and Git mutation stay behind review.
- Synced current test-count docs without changing generated Habitat output.

## Reason

Secret-bearing search guidance is useful only if it does not leak into clean-project investigation. These self-use fixtures already recorded that distinction, but they were not executable test contracts.

## Expected Behavior

- Future changes that over-constrain no-secret `rg` inspection or skip existing evidence checks fail closer to the behavior fixture.
- Agents continue to treat secret-bearing search caution as conditional, not as a blanket ban on ordinary project inspection.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- No-secret self-use runs keep using bounded read-only search before speculative policy or evidence changes.
- Secret-bearing fixtures remain the place for exclusion-aware search behavior.

## Failure Signals

- Agents require policy review for every ordinary no-secret source or docs search.
- The tests duplicate fixture parsing without catching command-decision drift.

## Result

Unjudged.
