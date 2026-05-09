---
type: nenrin_change
id: baseline-command-catalog-test-boundary
date: 2026-05-10
status: observing
impact: unknown
related_files:
  - Tests/HabitatCoreTests/BaselineCommandCatalogTests.swift
  - Tests/HabitatCoreTests/PolicyReasonCatalogTests.swift
  - docs/current_status.md
  - docs/roadmap.md
review_after:
  tasks: 3
  days: 7
---

# Change: baseline-command-catalog-test-boundary

## Changed

- Moved baseline command-catalog ownership, duplicate-entry, static-family coverage, and unowned-command tests into `BaselineCommandCatalogTests.swift`.
- Left `PolicyReasonCatalogTests.swift` focused on package-manager review routing and reason-code classification contracts.
- Preserved generated policy output and command counts.

## Reason

The baseline catalog drift checks had become the first block in the reason-routing suite. Keeping them in a dedicated test boundary makes future baseline policy maintenance start from the ownership and duplication contracts instead of mixing those checks with reason-rule behavior.

## Expected Behavior

- Future baseline command-family edits update one catalog-owned family list and run the dedicated baseline catalog tests.
- Reason-routing tests stay focused on classification order and fallback behavior.
- No generated Markdown or JSON policy output changes from this test-only move.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- A future baseline policy edit starts in `BaselineCommandCatalogTests` when checking ownership or duplicates.
- `PolicyReasonCatalogTests` remains focused on reason-code routing rather than baseline list bookkeeping.

## Failure Signals

- New baseline drift checks are added back into the broad reason-routing test suite.
- Generated policy changes without a nearby baseline catalog ownership check.

## Result

Unjudged.
