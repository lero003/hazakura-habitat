---
type: nenrin_change
id: skill-helper-source-build-first
date: 2026-05-15
status: observing
impact: unknown
related_files:
  - skills/hazakura-habitat/scripts/run_habitat_scan.sh
  - skills/hazakura-habitat/SKILL.md
  - Tests/HabitatCoreTests/ScanExecutionInfrastructureTests.swift
  - Tests/HabitatCoreTests/ScanComparisonTests.swift
  - docs/current_status.md
review_after:
  tasks: 3
  days: 7
---

# Change: skill-helper-source-build-first

## Changed

- Made the bundled Habitat skill helper rebuild the source checkout before using existing build, dist, or PATH habitat-scan binaries, including external observation scans.

## Reason

Cross-project intake showed a stale PATH binary could make --previous-scan report preferred-command drift that contradicted the current source checkout output.

## Expected Behavior

- Future external scans from the Habitat checkout use the current generator contract before comparing stale saved reports.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- External observation scans from the Habitat checkout use the source-built helper binary before PATH.
- `--previous-scan` preferred-command deltas match the current generated `Prefer` list.
- Agents do not report stale release-binary behavior as a current scanner bug.

## Failure Signals

- The helper still picks an installed or packaged binary before the current checkout.
- Rebuild fallback noise makes routine fresh scans hard to read.
- Agents bypass the helper to avoid stale-binary uncertainty.

## Result

Unjudged.
