---
type: nenrin_change
id: policy-finding-command-reasons
date: 2026-05-04
status: reviewed
impact: effective
related_files:
  - Sources/HabitatCore/Models.swift
  - Sources/HabitatCore/PolicyReasonCatalog.swift
  - Tests/HabitatCoreTests/HabitatCoreTests.swift
  - docs/current_status.md
  - CHANGELOG.md
review_after:
  tasks: 3
  days: 7
---

# Change: policy-finding-command-reasons

## Changed

- Added a thin `PolicyFinding` model for command policy decisions.
- Routed generated command-reason metadata through `PolicyFinding` before converting it to the existing `PolicyCommandReason` JSON shape.
- Added a focused test proving `PolicyFinding` backs command-reason metadata for an Ask First and Forbidden command.

## Reason

The re-scoped `v0.4` roadmap needs a visible policy-decision core without forcing the full scanner-to-renderer pipeline to land before release. `policy.commandReasons` was the smallest generated policy path that could move through a `PolicyFinding`-like concept while preserving compatibility for existing `scan_result.json` consumers.

## Expected Behavior

- Generated output shape remains compatible.
- Policy reason metadata comes from explicit policy findings instead of directly mapping command strings to JSON records.
- Future policy paths can migrate to `PolicyFinding` without requiring a broad refactor.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- New policy-decision tests can target `PolicyFinding` data.
- Later renderer work consumes policy-decision data without adding Markdown-only rules.
- Self-use and release review can judge `v0.4` by this visible foundation rather than by a full evidence pipeline.

## Failure Signals

- `PolicyFinding` remains a pass-through wrapper with no further migration path.
- New command families bypass `PolicyFinding` and add separate renderer logic.
- Generated JSON compatibility breaks unexpectedly.

## Result

Reviewed on 2026-05-05: keep. The evidence shows `PolicyFinding`-backed command reasons changed publication decisions without requiring a broad normalized-evidence layer or generated JSON shape change.
