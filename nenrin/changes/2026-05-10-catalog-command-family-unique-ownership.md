---
type: nenrin_change
id: catalog-command-family-unique-ownership
date: 2026-05-10
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/PolicyReasonCatalog+CommandFamilies.swift
  - Tests/HabitatCoreTests/BaselineCommandCatalogTests.swift
review_after:
  tasks: 3
  days: 7
---

# Change: catalog-command-family-unique-ownership

## Changed

- Removed aggregate review/execution family entries from `PolicyReasonCatalog.catalogCommandFamilies`.
- Added a `BaselineCommandCatalogTests` contract requiring each manifest command to have exactly one family owner.

## Reason

The catalog manifest is most useful when it points to one concrete owner for each command. Aggregate helper lists such as review-routing views can make drift failures ambiguous because the same command appears under more than one family.

## Expected Behavior

- Generated policy output, command order, reason codes, Markdown, and JSON stay unchanged.
- Future command-family additions either belong to one concrete manifest family or fail the manifest contract.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later catalog edits fail with a concrete duplicate-owner message when a command is accidentally listed twice.
- Review-routing helper lists can keep aggregating commands without becoming manifest owners.

## Failure Signals

- A future catalog change needs multi-owner manifest entries to explain generated policy drift.

## Result

Unjudged.
