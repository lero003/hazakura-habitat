---
type: nenrin_change
id: typed-command-family-manifest-entry
date: 2026-05-10
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/PolicyReasonCatalog.swift
  - Sources/HabitatCore/PolicyReasonCatalog+BaselinePolicy.swift
  - Sources/HabitatCore/PolicyReasonCatalog+CommandFamilies.swift
  - Tests/HabitatCoreTests/BaselineCommandCatalogTests.swift
  - docs/current_status.md
  - docs/roadmap.md
  - docs/self_use.md
review_after:
  tasks: 3
  days: 7
---

# Change: typed-command-family-manifest-entry

## Changed

- Added a typed `CommandFamilyManifestEntry` for catalog-owned family manifests.
- Switched baseline and catalog command-family manifests from tuple lists to typed entries.
- Added a baseline manifest-name uniqueness contract in `BaselineCommandCatalogTests`.

## Reason

The catalog manifest is now the local ownership point for command-family drift. A typed entry keeps the manifest shape explicit as more families are split or renamed, while the new test catches duplicate baseline family names before they obscure ownership.

## Expected Behavior

- Generated policy output, command order, reason codes, Markdown, and JSON stay unchanged.
- Future baseline family edits use the same typed manifest shape and keep family names unique.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later command-family additions or renames update typed manifest entries without test-local bookkeeping.
- Baseline ownership stays readable without changing generated policy behavior.

## Failure Signals

- Manifest names drift from the command-family they describe.
- New baseline families are added without exercising the uniqueness contract.

## Result

Unjudged.
