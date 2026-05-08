---
type: nenrin_change
id: forbidden-fallback-order-contract
date: 2026-05-09
status: observing
impact: unknown
related_files:
  - Tests/HabitatCoreTests/PolicyReasonCatalogTests.swift
  - CHANGELOG.md
  - docs/current_status.md
  - docs/roadmap.md
  - docs/self_use.md
review_after:
  tasks: 3
  days: 7
---

# Change: forbidden-fallback-order-contract

## Changed

- Added a `PolicyReasonCatalogTests` contract for Forbidden reason-rule ordering.
- Documented that remote scripts, host-private reads, credential access, and global host mutation keep their specific reason families before generic unsafe-command fallback.

## Reason

Forbidden policy entries are most useful when the refusal reason names the actual risk. A generic unsafe-command fallback is still needed for unknown sensitive entries, but it should not hide sharper command families such as credential access or host-private data.

## Expected Behavior

- Future Forbidden command-family edits keep specific reason rules ahead of the generic fallback.
- Agents reading `command_policy.md` or `scan_result.json` see precise refusal metadata when a specific risk family exists.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later Forbidden policy additions preserve specific reason codes without weakening the generic fallback.
- A future fallback-order regression fails in `PolicyReasonCatalogTests` before generated output drifts.

## Failure Signals

- The contract becomes too sample-specific and misses a real rule-order regression.
- New Forbidden command families still fall through to `unsafe_or_sensitive_command` when a specific reason would better change agent behavior.

## Result

Unjudged.
