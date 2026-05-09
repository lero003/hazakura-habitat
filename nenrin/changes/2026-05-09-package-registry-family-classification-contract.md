---
type: nenrin_change
id: package-registry-family-classification-contract
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

# Change: package-registry-family-classification-contract

## Changed

- Added a PolicyReasonCatalogTests contract proving every catalog-owned package-registry mutation command maps to `package_registry_mutation`, not only representative publish/yank examples.

## Reason

Package-registry commands are dependency-shaped enough to fall through to generic dependency-mutation reasoning if catalog routing drifts. Agents need those commands to keep external package-state risk visible before publish, owner, dist-tag, trunk, or upload commands are considered.

## Expected Behavior

- Future package-registry catalog edits fail tests if a new command is added without preserving package-registry reason metadata.
- Generated command policy keeps registry publication and metadata mutation distinct from ordinary dependency install/update risk.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later package-registry command additions keep `package_registry_mutation` without relying on generic dependency fallback.
- Agents continue to see external registry-state risk in reason metadata before package publication or ownership commands.

## Failure Signals

- The family-level contract becomes too broad for package-manager commands that should intentionally use another reason code.
- Generated policy collapses new registry actions back into `dependency_mutation`.

## Result

Unjudged.
