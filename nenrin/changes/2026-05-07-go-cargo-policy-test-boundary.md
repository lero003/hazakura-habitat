---
type: nenrin_change
id: go-cargo-policy-test-boundary
date: 2026-05-07
status: observing
impact: unknown
related_files:
  - Tests/HabitatCoreTests/GoCargoPolicyTests.swift
  - Tests/HabitatCoreTests/PackageAndCommandPolicyTests.swift
review_after:
  tasks: 3
  days: 7
---

# Change: go-cargo-policy-test-boundary

## Changed

- Split Go/Cargo scanner policy scenarios into `GoCargoPolicyTests.swift`.
- Kept generated policy behavior unchanged while reducing `PackageAndCommandPolicyTests.swift`.

## Reason

`PackageAndCommandPolicyTests.swift` still carries broad scanner-package-manager coverage. Go/Cargo has a cohesive command-decision boundary already mirrored by `PolicyReasonCatalog+GoCargo.swift`, so the tests should have the same local ownership before nearby behavior grows.

## Expected Behavior

- Future Go/Cargo scanner or policy edits start in the dedicated suite.
- Agents can choose the narrow test owner without reading the larger package-policy suite first.
- No generated output, reason-code, or command-order behavior changes from this split alone.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later Go/Cargo changes update `GoCargoPolicyTests.swift` directly.
- `PackageAndCommandPolicyTests.swift` stops accumulating Go/Cargo-only cases.
- `swift test` and the test-annotation contract keep coverage executable.

## Failure Signals

- New Go/Cargo cases are added back to `PackageAndCommandPolicyTests.swift`.
- The suite boundary causes duplicate fixtures or hides shared package-manager behavior.

## Result

Unjudged.
