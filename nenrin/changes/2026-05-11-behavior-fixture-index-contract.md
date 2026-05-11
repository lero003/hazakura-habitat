---
type: nenrin_change
id: behavior-fixture-index-contract
date: 2026-05-11
status: observing
impact: unknown
related_files:
  - Tests/HabitatCoreTests/BehaviorEvidenceSanitizationTests.swift
  - examples/README.md
  - docs/evaluation.md
review_after:
  tasks: 3
  days: 7
---

# Change: behavior-fixture-index-contract

## Changed

- Added a behavior-evidence contract that every JSON fixture under `examples/behavior-evaluation/` is listed in both `examples/README.md` and `docs/evaluation.md`.
- Added the missing README entries for the instruction-claim and CI uncertainty fixtures.
- Added the missing `ci-workflow-no-local-validation-001` evaluation summary.

## Reason

Behavior fixtures are useful only when the next agent can find the command-decision evidence they represent. The fixture set had already drifted: instruction-alignment and CI uncertainty evidence existed, but the public indexes were incomplete.

## Expected Behavior

- Future fixture additions update the discoverability docs in the same slice.
- Agents can find existing instruction-alignment and CI uncertainty evidence before inventing new evidence-normalization work.
- Missing index updates fail in tests instead of lingering as documentation drift.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- New behavior fixtures land with README and evaluation summaries.
- Future agents reuse existing CI/instruction evidence before adding overlapping fixtures.

## Failure Signals

- The index contract becomes noisy because fixture summaries are no longer useful.
- Agents add index entries mechanically without preserving command-decision summaries.

## Result

Unjudged.
