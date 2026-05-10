---
type: nenrin_change
id: catalog-family-rendered-side-contract
date: 2026-05-11
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

# Change: catalog-family-rendered-side-contract

## Changed

- Added a `BaselineCommandCatalogTests` contract that checks each catalog-family source against the rendered Ask First / Forbidden policy side.
- Kept dynamic Ask First families outside static baseline policy while still requiring Ask First metadata for those dynamic commands.
- Synced the status, roadmap, and self-use notes with the added catalog drift contract.

## Reason

The catalog manifest now carries source labels, but future edits also need to keep those labels tied to the rendered policy side. A family that looks owned and classified correctly can still mislead maintainers if it is accidentally rendered through the wrong baseline list.

## Expected Behavior

- Future catalog edits fail locally if a baseline Ask First family appears in Forbidden policy, a Forbidden family appears in Ask First policy, or a dynamic Ask First family is duplicated into static baseline policy.
- Generated Markdown, JSON policy metadata, command order, and reason codes stay unchanged.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- A future catalog-family move catches source/rendering drift before generated policy output changes.

## Failure Signals

- The contract duplicates existing tests without catching any future manifest-side mistake.

## Result

Unjudged.
