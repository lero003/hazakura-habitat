---
type: nenrin_change
id: secret-bearing-behavior-test-boundary
date: 2026-05-13
status: observing
impact: unknown
related_files:
  - Tests/HabitatCoreTests/SecretBearingBehaviorEvaluationTests.swift
  - Tests/HabitatCoreTests/BehaviorEvaluationTests.swift
  - docs/current_status.md
  - docs/roadmap.md
review_after:
  tasks: 3
  days: 7
---

# Change: secret-bearing-behavior-test-boundary

## Changed

- Moved secret-bearing search and no-secret search behavior fixture tests into `SecretBearingBehaviorEvaluationTests.swift`.
- Kept fixture content and generated output behavior unchanged.

## Reason

Secret-bearing search behavior is a repeated command-decision boundary: agents should reshape broad search and export, but still inspect named non-secret source files. Giving that evidence its own test boundary keeps future policy regressions easier to review without growing the broader self-use behavior suite.

## Expected Behavior

- Agents add future secret-bearing search fixture assertions to the dedicated test file.
- `BehaviorEvaluationTests.swift` stays focused on general self-use behavior evidence.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later secret-bearing search evidence lands in the dedicated suite.
- The split reduces navigation cost without changing test behavior.

## Failure Signals

- New secret-bearing behavior checks return to the general behavior suite.
- The boundary encourages speculative secret-evidence expansion without a command-changing observation.

## Result

Unjudged.
