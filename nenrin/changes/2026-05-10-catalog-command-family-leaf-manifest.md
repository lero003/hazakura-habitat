---
type: nenrin_change
id: catalog-command-family-leaf-manifest
date: 2026-05-10
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/PolicyReasonCatalog+CommandFamilies.swift
  - Tests/HabitatCoreTests/BaselineCommandCatalogTests.swift
  - docs/current_status.md
  - docs/roadmap.md
  - docs/self_use.md
review_after:
  tasks: 3
  days: 7
---

# Change: catalog-command-family-leaf-manifest

## Changed

- Removed rendered baseline aggregate entries from `PolicyReasonCatalog.catalogCommandFamilies`.
- Added a `BaselineCommandCatalogTests` contract that keeps the catalog manifest focused on concrete leaf command families.
- Synced status, roadmap, and self-use docs with the tighter manifest boundary.

## Reason

The catalog manifest exists to catch drift in concrete command-family ownership. Including already-rendered baseline aggregates made the manifest less precise because the same policy entries appeared both as leaf families and as aggregate lists.

## Expected Behavior

- Generated policy output, command order, reason codes, Markdown, and JSON stay unchanged.
- Future catalog drift checks focus on concrete command families.
- Baseline rendered list changes remain covered by existing baseline ownership and duplicate-entry contracts.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later command-family edits add or rename leaf manifest entries without reintroducing aggregate rendered lists.
- Catalog drift failures point to concrete family ownership rather than aggregate baseline output.

## Failure Signals

- A future test needs aggregate baseline entries to diagnose generated-policy drift.
- Manifest ownership becomes unclear when broad baseline policy lists change.

## Result

Unjudged.
