---
type: nenrin_change
id: previous-scan-preferred-values
date: 2026-05-16
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/Models.swift
  - Sources/HabitatCore/ScanComparator.swift
  - Tests/HabitatCoreTests/ScanComparisonTests.swift
  - docs/agent_contract.md
  - docs/current_status.md
review_after:
  tasks: 3
  days: 7
---

# Change: previous-scan-preferred-values

## Changed

- Added structured `previousValues` and `currentValues` arrays to
  preferred-command `changes` emitted by `--previous-scan`.
- Kept the existing human-readable summary and impact text unchanged.
- Documented the additive JSON fields for `v0.x` machine consumers.

## Reason

Cross-project intake again found a saved ai-mobile report whose preferred
commands still included raw Gradle peers while the fresh scan selected only the
project-local validation wrapper. The Markdown note was clear for humans, but
machine consumers still had to parse the summary string to know which preferred
commands were stale.

## Expected Behavior

- Agents and scripts that read `scan_result.json` can follow the current
  preferred command list directly.
- Saved-report comparison stays advisory and does not become report lifecycle
  automation.
- Non-preferred-command changes remain concise until observation shows another
  category needs structured values.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Future stale preferred-command checks use `currentValues` rather than parsing
  summary text.
- Agents avoid stale raw package-manager peers when current preferred commands
  narrow to a project-local wrapper.

## Failure Signals

- Consumers treat `previousValues` as permission to run stale commands.
- The same structure spreads to broad change categories without a
  command-decision need.

## Result

Unjudged.
