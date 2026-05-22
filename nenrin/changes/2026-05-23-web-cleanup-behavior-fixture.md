---
type: nenrin_change
id: web-cleanup-behavior-fixture
date: 2026-05-23
status: observing
impact: unknown
related_files:
  - examples/behavior-evaluation/cross-project-web-cleanup-validation-001.json
  - Tests/HabitatCoreTests/CrossProjectBehaviorEvaluationTests.swift
  - docs/evaluation.md
review_after:
  tasks: 3
  days: 7
---

# Change: web-cleanup-behavior-fixture

## Changed

- Added one behavior fixture for repeated external web cleanup reports.
- Fixed the current judgment: runtime mismatch warnings, `npm run build`, and
  mutation guards are useful evidence, while dead asset detection, CSS dead-code
  scanning, and automatic re-scan hooks stay parked.

## Reason

Post-v1 work needs a loose way to keep useful external-use signals without
turning every attractive cleanup idea into scanner scope. This fixture records
the command-decision effect and the no-expansion boundary together.

## Expected Behavior

- Future web cleanup observations can compare against this fixture before
  proposing new Habitat behavior.
- Agents keep using current runtime, validation, and mutation guidance first.
- Cleanup intelligence only moves forward after a repeated command-safety,
  validation-choice, stale-report, or mutation-boundary failure.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later web cleanup intake either remains no-op or adds a narrower follow-up
  because the command-decision gap is explicit.
- Post-v1 work keeps preferring observation-led pruning or small freshness
  checks over broad scanner expansion.

## Failure Signals

- The fixture is used to justify dead asset or CSS scanning without a new
  command-decision failure.
- Automatic report refresh hooks are promoted before repeated stale-report
  over-trust appears.

## Result

Unjudged.
