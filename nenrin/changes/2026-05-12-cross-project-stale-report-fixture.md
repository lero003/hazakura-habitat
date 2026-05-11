---
type: nenrin_change
id: cross-project-stale-report-fixture
date: 2026-05-12
status: observing
impact: unknown
related_files:
  - examples/behavior-evaluation/cross-project-stale-report-001.json
  - Tests/HabitatCoreTests/BehaviorEvaluationTests.swift
  - examples/README.md
  - docs/evaluation.md
review_after:
  tasks: 3
  days: 7
---

# Change: cross-project-stale-report-fixture

## Changed

- Added sanitized behavior evidence for cross-project stale-report refresh: stale saved reports are refreshed into temporary output, compared only for command-changing guidance, and watched projects remain read-only.

## Reason

The daily Habitat loop now observes sibling projects before choosing a local slice; this rule should stay durable without copying raw report output or expanding into Android/Python work.

## Expected Behavior

- Agents downgrade stale reports to bounded uncertainty, run temporary fresh scans when needed, and carry back only Habitat-side command-decision changes.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Future cross-project intakes refresh stale or missing reports into temporary output before trusting command guidance.
- Agents keep watched projects read-only when a fresh scan confirms existing guidance.

## Failure Signals

- Agents treat stale saved reports as current despite key project-file changes.
- Cross-project intake starts editing watched projects or copying raw report output into Habitat/Nenrin.

## Result

Unjudged.
