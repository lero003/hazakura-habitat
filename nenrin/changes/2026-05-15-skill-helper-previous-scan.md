---
type: nenrin_change
id: skill-helper-previous-scan
date: 2026-05-15
status: observing
impact: unknown
related_files:
  - skills/hazakura-habitat/SKILL.md
  - skills/hazakura-habitat/scripts/run_habitat_scan.sh
  - Tests/HabitatCoreTests/ScanExecutionInfrastructureTests.swift
review_after:
  tasks: 3
  days: 7
---

# Change: skill-helper-previous-scan

## Changed

- Let the bundled skill helper accept an optional previous report path as its
  third argument and pass it through as `--previous-scan`.
- Documented the helper form for refreshing stale saved reports without writing
  over the old report directory.
- Added a helper regression test that proves the previous-scan argument is
  preserved.

## Reason

Cross-project intake found that stale saved reports are best handled by a fresh
temporary scan plus `--previous-scan`, but agents had to drop from the helper to
raw CLI syntax to do that comparison. The helper should support the same bounded
consumption path without becoming a report lifecycle tool.

## Expected Behavior

- Agents can keep using the bundled helper during stale-report intake.
- Fresh scans can surface preferred-command drift while leaving watched-project
  report directories untouched.
- The helper remains advisory plumbing and does not install, repair, or clean
  reports.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Future cross-project intake uses helper plus previous-scan instead of manual
  report comparison.
- Stale preferred-command drift is visible in current generated context.
- Watched projects remain read-only.

## Failure Signals

- Agents still bypass the helper for previous-scan comparison.
- The helper starts being treated as a report cleanup or lifecycle command.

## Result

Unjudged.
