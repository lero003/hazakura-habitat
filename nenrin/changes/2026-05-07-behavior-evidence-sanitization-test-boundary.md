---
type: nenrin_change
id: behavior-evidence-sanitization-test-boundary
date: 2026-05-07
status: observing
impact: unknown
related_files:
  - Tests/HabitatCoreTests/BehaviorEvidenceSanitizationTests.swift
  - Tests/HabitatCoreTests/BehaviorEvaluationTests.swift
  - docs/current_status.md
  - docs/roadmap.md
  - docs/self_use.md
review_after:
  tasks: 3
  days: 7
---

# Change: behavior-evidence-sanitization-test-boundary

## Changed

- Moved cross-fixture behavior-evidence schema and sanitization checks into `BehaviorEvidenceSanitizationTests.swift`.
- Kept behavior fixtures, generated output, reason codes, command ordering, and individual behavior-decision assertions unchanged.

## Reason

Behavior evidence is a post-`v0.4` decision input, but its privacy and schema contract is different from each fixture's command-decision assertion. A dedicated suite should make future fixture additions check sanitization without growing the already-large behavior evaluation cases.

## Expected Behavior

- Future behavior fixture additions keep schema and sanitization checks in `BehaviorEvidenceSanitizationTests.swift`.
- `BehaviorEvaluationTests.swift` stays focused on whether Habitat changed the agent's next command.
- The split remains no-output-change and no-fixture-change.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- A later behavior fixture addition fails or passes the shared sanitization contract without touching individual fixture assertions.
- The behavior-evidence boundary keeps raw prompts, private paths, and secret-like snippets out of recorded fixtures.

## Failure Signals

- New sanitization checks drift back into individual behavior-decision tests.
- A future fixture bypasses the shared schema or sanitization contract.

## Result

Unjudged.
