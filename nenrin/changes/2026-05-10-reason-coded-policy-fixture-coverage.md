---
type: nenrin_change
id: reason-coded-policy-fixture-coverage
date: 2026-05-10
status: observing
impact: unknown
related_files:
  - Tests/HabitatCoreTests/BehaviorEvaluationTests.swift
  - examples/behavior-evaluation/swiftpm-self-use-012.json
  - docs/current_status.md
  - docs/roadmap.md
  - docs/self_use.md
review_after:
  tasks: 3
  days: 7
---

# Change: reason-coded-policy-fixture-coverage

## Changed

- Added executable behavior-evaluation coverage for the existing `swiftpm-self-use-012` fixture.
- Pinned the observed path where reason-coded `git_mutation` and `dependency_resolution_mutation` guidance changed publication from broad staging into policy review, verification, and explicit-file staging.
- Synced current test-count docs without changing generated Habitat output.

## Reason

The fixture already documented command-changing self-use evidence, but it was not an executable regression contract. That left the reason-coded policy publication behavior easier to drift than adjacent self-use fixtures.

## Expected Behavior

- Future changes that weaken Git mutation policy review or explicit-file staging evidence fail closer to the behavior fixture.
- Agents continue to rely on existing PolicyFinding command reasons before inventing a broader evidence-normalization layer.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Self-use publication slices keep reviewing `command_policy.md` before Git mutation.
- Behavior fixtures remain executable checks, not only documentation examples.

## Failure Signals

- Agents return to `git add .` or skip policy review before committing.
- The test duplicates fixture parsing without catching command-decision drift.

## Result

Unjudged.
