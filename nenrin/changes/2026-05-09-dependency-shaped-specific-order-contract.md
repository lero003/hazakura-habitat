---
type: nenrin_change
id: dependency-shaped-specific-order-contract
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

# Change: dependency-shaped-specific-order-contract

## Changed

- Added a `PolicyReasonCatalogTests` contract for dependency-shaped Ask First reason-rule ordering.
- Documented that package registry mutation, Corepack activation, and ephemeral package execution keep their specific reason families before generic dependency-mutation fallback.

## Reason

Several specific Ask First families contain words such as `install`, `publish`, `push`, or `yank` that also match the broad dependency-mutation fallback. Those commands should keep command-changing reason metadata about external registry state, package-manager activation, or unpinned execution instead of collapsing into a generic dependency edit explanation.

## Expected Behavior

- Future dependency-shaped command-family edits preserve specific reason codes before the generic fallback.
- Agents reading `command_policy.md` or `scan_result.json` see the sharper command risk when a specific family exists.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later catalog additions keep specific reason codes without weakening the dependency fallback.
- A future rule-order regression fails in `PolicyReasonCatalogTests` before generated output drifts.

## Failure Signals

- The contract becomes sample-specific and misses another dependency-shaped family.
- New package or registry commands fall through to `dependency_mutation` even when a specific reason would better guide the next command.

## Result

Unjudged.
