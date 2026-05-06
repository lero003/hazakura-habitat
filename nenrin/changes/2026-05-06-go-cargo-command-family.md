---
type: nenrin_change
id: go-cargo-command-family
date: 2026-05-06
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/PolicyReasonCatalog+GoCargo.swift
  - Sources/HabitatCore/PolicyReasonCatalog.swift
  - Sources/HabitatCore/Scanner.swift
  - Tests/HabitatCoreTests/PackageAndCommandPolicyTests.swift
  - docs/current_status.md
review_after:
  tasks: 3
  days: 7
---

# Change: go-cargo-command-family

## Changed

- Centralized Go and Cargo dependency-mutation command arrays in `PolicyReasonCatalog`.
- Made scanner Ask First command generation and selected Go/Cargo review ordering consume catalog-owned arrays.
- Added catalog classification coverage so Go and Cargo dependency mutations keep their current `dependency_mutation` reason code.

## Reason

The post-v0.4 self-scan still showed long command-policy output as active command-decision context. Go and Cargo were small remaining scanner-local package-manager families, which made future mutation-policy edits easier to drift from catalog-owned review ordering.

## Expected Behavior

- Generated command lists and ordering remain unchanged for existing fixtures.
- `go get` and `go mod tidy` keep `dependency_mutation`.
- `cargo add`, `cargo update`, and `cargo remove` keep `dependency_mutation`.
- Future Go or Cargo policy edits have one command-family owner for scanner generation and review ordering.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Go and Cargo command reasons do not regress into generic approval metadata.
- Future Go/Cargo policy changes reuse catalog-owned arrays instead of scanner-local duplicates.
- Generated policy counts stay stable unless a behavior-driven command addition intentionally changes them.

## Failure Signals

- Generated Ask First ordering changes unexpectedly.
- Go/Cargo policy broadens into ecosystem inventory without observed command-decision need.
- Selected review ordering diverges from the full command policy.

## Result

Unjudged.
