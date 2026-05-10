---
type: nenrin_change
id: baseline-rendered-policy-order-contract
date: 2026-05-10
status: observing
impact: unknown
related_files:
  - Tests/HabitatCoreTests/BaselineCommandCatalogTests.swift
  - docs/current_status.md
  - docs/roadmap.md
  - docs/self_use.md
review_after:
  tasks: 3
  days: 7
---

# Change: baseline-rendered-policy-order-contract

## Changed

- Added a `BaselineCommandCatalogTests` contract that requires rendered baseline Ask First and Forbidden command order to follow the catalog family manifest order.
- Updated status, roadmap, and self-use notes to name rendered-order preservation as part of the catalog drift boundary.
- Preserved generated policy output, reason-code mapping, scanner behavior, and command counts.

## Reason

The catalog family manifest is now the source of ownership truth. If rendered baseline policy order can drift away from that manifest, a future family edit could look owned and classified correctly while still reshaping the long policy in a harder-to-review way.

## Expected Behavior

- Future baseline family edits fail locally if aggregate command order stops following the manifest.
- Agents keep seeing stable `command_policy.md` ordering unless a change intentionally updates the catalog family order.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- A future policy-order change is explicit in the catalog manifest rather than hidden in aggregate construction.
- No generated Markdown or JSON churn is needed for this contract.

## Failure Signals

- The contract becomes redundant noise because rendered order is protected elsewhere with clearer diagnostics.

## Result

Unjudged.
