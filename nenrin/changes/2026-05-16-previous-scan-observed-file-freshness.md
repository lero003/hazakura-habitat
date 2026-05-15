---
type: nenrin_change
id: previous-scan-observed-file-freshness
date: 2026-05-16
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/ScanComparator.swift
  - Tests/HabitatCoreTests/CrossProjectBehaviorEvaluationTests.swift
  - Tests/HabitatCoreTests/ScanComparisonTests.swift
  - docs/current_status.md
  - docs/evaluation.md
  - examples/behavior-evaluation/cross-project-previous-scan-preferred-delta-001.json
review_after:
  tasks: 3
  days: 7
---

# Change: previous-scan-observed-file-freshness

## Changed

- Added an `observed_files` previous-scan change when observed project files are
  added, removed, or modified between a saved report and a fresh scan.
- Included structured `previousValues` and `currentValues` labels with file path
  and modification time for the changed observed files.
- Kept the behavior scoped to `--previous-scan` comparison output.

## Reason

Cross-project intake found an ai-mobile saved report whose key docs changed
after the saved scan. Preferred-command drift happened in this case too, but
future stale reports should not require humans or scripts to infer staleness
only from a changed preferred-command list.

## Expected Behavior

- Agents treat saved reports with changed observed files as stale context and
  use the current generated context before choosing commands.
- Machine consumers can identify which observed files changed without parsing
  summary prose.
- Habitat remains an advisory freshness comparator, not a report lifecycle or
  workspace intelligence tool.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Future cross-project intake downgrades stale saved reports from
  `observed_files` changes even when preferred commands remain unchanged.
- Agents stop hand-comparing `Scanned at` against key file mtimes for the common
  previous-scan path.

## Failure Signals

- The change becomes noisy enough that agents ignore previous-scan deltas.
- Consumers treat observed-file change records as a plan or backlog for the
  watched repository.

## Result

Unjudged.
