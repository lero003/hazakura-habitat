---
type: nenrin_change
id: baseline-family-leaf-order-contract
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

# Change: baseline-family-leaf-order-contract

## Changed

- Added `BaselineCommandCatalogTests` contracts that pin the current baseline Ask First and Forbidden leaf-family manifest order.
- Synced self-use and roadmap/status notes with the added leaf-order contract.
- Preserved generated policy output, command order, reason-code mapping, and scanner behavior.

## Reason

The catalog manifest is now the coordination point for baseline policy ownership. Pinning the leaf-family order makes future additions deliberate instead of allowing a broad aggregate or accidental reorder to silently change the catalog boundary.

## Expected Behavior

- Future baseline catalog additions update the explicit leaf-family contract in the same slice.
- Agents and maintainers keep treating catalog edits as order-sensitive policy maintenance, even when generated Markdown output does not change.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- A future baseline family addition fails locally until the manifest order is reviewed and updated intentionally.
- Generated policy output remains stable across catalog-maintenance slices.

## Failure Signals

- The exact-order contract causes noisy churn without catching meaningful catalog drift.

## Result

Unjudged.
