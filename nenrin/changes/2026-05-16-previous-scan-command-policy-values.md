---
type: nenrin_change
id: previous-scan-command-policy-values
date: 2026-05-16
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/ScanComparator.swift
  - Tests/HabitatCoreTests/ScanComparisonTests.swift
  - docs/current_status.md
review_after:
  tasks: 3
  days: 7
---

# Change: previous-scan-command-policy-values

## Changed

- Added structured `previousValues` and `currentValues` to previous-scan
  `command_policy` deltas.
- Covered added, resolved, and newly forbidden policy entries in
  `ScanComparisonTests` without changing the short `agent_context.md` note
  shape.
- Updated current status so the previous-scan output contract describes
  command-policy values alongside observed-file and preferred-command values.

## Reason

Post-`v0.7` stale-report consumption should not require machine consumers to
parse command-policy summary prose before deciding whether current Ask First or
Forbidden guidance changed.

## Expected Behavior

- Agents and scripts can identify Ask First and Forbidden policy drift from
  structured `scan_result.json` values while `agent_context.md` stays concise.
- Current command policy remains authoritative; previous reports are evidence
  for drift, not permission to keep old approval or refusal decisions.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Future stale-report consumers handle command-policy drift from
  `previousValues` / `currentValues` without scraping the summary sentence.
- The short previous-scan note remains readable when command-policy deltas are
  large or mixed with preferred-command drift.

## Failure Signals

- Consumers misread equal previous/current arrays on Ask First -> Forbidden
  transitions as no change.
- Command-policy deltas become noisy enough that agents ignore current
  `command_policy.md`.

## Result

Unjudged.
