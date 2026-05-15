---
type: nenrin_change
id: skill-helper-auto-previous-scan
date: 2026-05-16
status: observing
impact: unknown
related_files:
  - docs/current_status.md
  - skills/hazakura-habitat/SKILL.md
  - skills/hazakura-habitat/scripts/run_habitat_scan.sh
  - Tests/HabitatCoreTests/ScanExecutionInfrastructureTests.swift
review_after:
  tasks: 3
  days: 7
---

# Change: skill-helper-auto-previous-scan

## Changed

- Made the bundled Habitat skill helper infer an existing
  `habitat-report/scan_result.json` as `--previous-scan` when the fresh scan is
  written to a separate output directory.
- Kept explicit third-argument `--previous-scan` support for callers that need
  to compare against a different report.
- Added helper regression tests for automatic comparison and for the in-place
  saved-report refresh boundary.

## Reason

Cross-project intake found that a stale saved ai-mobile report still showed raw
Gradle preferred commands, while a fresh temporary scan correctly preferred only
the project-local validation wrapper. The helper already supported
`--previous-scan`, but agents still had to remember to pass the saved report
when refreshing into a temporary directory.

## Expected Behavior

- Fresh temporary scans surface saved-report preferred-command drift by default.
- Watched projects remain read-only when the output path is outside the project.
- Normal in-place saved-report refreshes do not compare the report to itself.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Future cross-project intake sees stale saved-report deltas without manual
  helper arguments.
- Agents choose current preferred commands instead of stale saved report
  guidance.

## Failure Signals

- The helper surprises callers by comparing reports during an in-place refresh.
- Agents treat the helper as report lifecycle automation instead of advisory
  scan plumbing.

## Result

Unjudged.
