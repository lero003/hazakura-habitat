---
type: nenrin_change
id: previous-scan-stale-preferred-delta
date: 2026-05-15
status: observing
impact: unknown
related_files:
  - examples/behavior-evaluation/cross-project-previous-scan-preferred-delta-001.json
  - Tests/HabitatCoreTests/CrossProjectBehaviorEvaluationTests.swift
  - docs/current_status.md
  - docs/evaluation.md
  - docs/roadmap.md
  - examples/README.md
review_after:
  tasks: 3
  days: 7
---

# Change: previous-scan-stale-preferred-delta

## Changed

- Added a cross-project behavior fixture for using `--previous-scan` against a
  saved sibling-project report.
- Covered the case where a fresh scan removes stale raw Gradle peers from
  preferred commands and keeps the project-local validation wrapper as the only
  current preferred command.
- Documented the consumption pattern in the evaluation notes and example index.

## Reason

Manual stale-report comparison found a command-changing preferred-command drift,
but `--previous-scan` already turns that drift into a short agent-facing note.
Recording this behavior keeps future automation on the existing advisory
comparison path instead of inventing watched-project edits or report lifecycle
features.

## Expected Behavior

- Cross-project intake uses `--previous-scan` when a saved report exists and
  may be stale.
- Agents follow current preferred commands after the comparison rather than
  stale raw package-manager peers.
- Watched projects remain read-only.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Future stale-report intake uses previous-scan comparison before hand-comparing
  preferred command sets.
- Stale preferred-command drift leads to current wrapper-first validation.
- No broad Android scanning or report lifecycle automation is added from this
  single consumption case.

## Failure Signals

- Agents continue trusting saved preferred commands after key files changed.
- Agents add watched-project work instead of treating the drift as Habitat-side
  consumption evidence.

## Result

Unjudged.
