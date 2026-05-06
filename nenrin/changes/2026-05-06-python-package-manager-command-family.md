---
type: nenrin_change
id: python-package-manager-command-family
date: 2026-05-06
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/PolicyReasonCatalog+PythonPackageManager.swift
  - Sources/HabitatCore/PolicyReasonCatalog.swift
  - Sources/HabitatCore/Scanner.swift
  - Tests/HabitatCoreTests/PackageAndCommandPolicyTests.swift
  - docs/current_status.md
review_after:
  tasks: 3
  days: 7
---

# Change: python-package-manager-command-family

## Changed

- Centralized pip install/uninstall, pip package fetch/cache, pip cache mutation, and uv mutation Ask First command arrays in `PolicyReasonCatalog`.
- Made scanner Ask First command generation and selected Python/uv review ordering consume those catalog-owned arrays.
- Added catalog classification coverage so Python dependency mutations keep `dependency_mutation` while pip fetch/index/search/cache-purge commands stay generic approval.

## Reason

The post-v0.4 self-scan still showed Python pip/uv policy as part of the long generated command-decision contract. Those command lists were duplicated between scanner generation and catalog classification, which made future pip or uv policy edits easier to drift.

## Expected Behavior

- Generated command lists and ordering remain unchanged for existing fixtures.
- pip install/uninstall, pip cache remove, and uv mutation commands keep `dependency_mutation`.
- pip download/wheel/index/search/cache purge commands keep generic approval metadata.
- Future Python package-manager policy edits have one command-family owner for scanner generation and review ordering.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Python package-manager Ask First commands stay stable in generated output snapshots.
- pip and uv command reasons do not regress into accidental fallback metadata.
- Future Python package-manager changes reuse catalog-owned arrays instead of reintroducing scanner-local duplicates.

## Failure Signals

- Generated Ask First command ordering changes unexpectedly.
- pip package fetch/cache commands receive stronger dependency-mutation wording without a measured behavior reason.
- The catalog grows broad Python tooling policy without a command-decision need.

## Result

Unjudged.
