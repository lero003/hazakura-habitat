---
type: nenrin_change
id: catalog-command-family-source-partition
date: 2026-05-10
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/PolicyReasonCatalog.swift
  - Sources/HabitatCore/PolicyReasonCatalog+CommandFamilies.swift
  - Sources/HabitatCore/PolicyReasonCatalog+BaselinePolicy.swift
  - Tests/HabitatCoreTests/BaselineCommandCatalogTests.swift
  - docs/current_status.md
  - docs/roadmap.md
review_after:
  tasks: 3
  days: 7
---

# Change: catalog-command-family-source-partition

## Changed

- Added a `BaselineCommandCatalogTests` contract requiring `PolicyReasonCatalog.catalogCommandFamilies` to equal dynamic families followed by baseline Ask First families and baseline Forbidden families.
- Added explicit source metadata to each `CommandFamilyManifestEntry`, so the partition boundary is recorded with each family instead of living only in array placement.
- Synced status and roadmap notes with the added catalog source-partition contract.
- Preserved generated policy output and command ordering.

## Reason

The catalog manifest is a maintainability contract, not a new policy source. Keeping its source partitions explicit should make future dynamic evidence additions deliberate and keep static baseline families separate from project-fact-driven command guidance.

## Expected Behavior

- Generated policy output, command order, reason codes, Markdown, and JSON stay unchanged.
- Future catalog manifest edits fail tests if they add extra families, omit a source partition, mislabel a source, or reorder the manifest away from the dynamic/static boundary.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Future catalog additions name whether they are dynamic, baseline Ask First, or baseline Forbidden before changing tests.
- Dynamic evidence work stays tied to a command-changing repository fact.

## Failure Signals

- The source-partition contract becomes churn without preventing catalog or generated-policy drift.

## Result

Unjudged.
