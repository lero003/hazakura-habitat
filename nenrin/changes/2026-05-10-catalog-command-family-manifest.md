---
type: nenrin_change
id: catalog-command-family-manifest
date: 2026-05-10
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/PolicyReasonCatalog+CommandFamilies.swift
  - Tests/HabitatCoreTests/BaselineCommandCatalogTests.swift
  - docs/current_status.md
  - docs/roadmap.md
review_after:
  tasks: 3
  days: 7
---

# Change: catalog-command-family-manifest

## Changed

- Added a catalog-owned command-family manifest in `PolicyReasonCatalog+CommandFamilies.swift`.
- Pointed the duplicate-entry contract in `BaselineCommandCatalogTests` at that manifest instead of keeping a long hand-maintained test-side list.
- Added a manifest inclusion check for baseline Ask First and Forbidden family names.
- Removed silent manifest-name deduplication, so duplicate family names remain visible to the duplicate-name contract instead of being filtered before tests inspect them.

## Reason

The previous duplicate-entry test already prevented command-family duplication, but its family list lived in the test file. Moving that manifest next to the catalog reduces drift when future policy families are split or renamed.

## Expected Behavior

- Generated policy output, command order, reason codes, Markdown, and JSON stay unchanged.
- Future command-family additions update the catalog manifest as part of the policy boundary, and the baseline catalog test catches omissions.
- Future duplicate family names fail loudly instead of being silently dropped from the manifest.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later catalog-family edits update `PolicyReasonCatalog+CommandFamilies.swift` instead of expanding test-local bookkeeping.
- Duplicate command-family checks remain in `BaselineCommandCatalogTests` without reintroducing reason-routing noise.

## Failure Signals

- New command families are added without entering the catalog manifest.
- Generated policy drift appears without a nearby manifest or baseline ownership check.

## Result

Unjudged.
