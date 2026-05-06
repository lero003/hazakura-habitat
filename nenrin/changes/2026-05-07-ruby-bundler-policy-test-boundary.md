---
type: nenrin_change
id: ruby-bundler-policy-test-boundary
date: 2026-05-07
status: observing
impact: unknown
related_files:
  - Tests/HabitatCoreTests/RubyBundlerPolicyTests.swift
  - Tests/HabitatCoreTests/PackageAndCommandPolicyTests.swift
review_after:
  tasks: 3
  days: 7
---

# Change: ruby-bundler-policy-test-boundary

## Changed

- Split Ruby Bundler scanner policy scenarios into `RubyBundlerPolicyTests.swift`.
- Kept generated policy behavior unchanged while reducing `PackageAndCommandPolicyTests.swift`.

## Reason

`PackageAndCommandPolicyTests.swift` still carries broad scanner-package-manager coverage. Bundler has a cohesive command-decision boundary already mirrored by `PolicyReasonCatalog+RubyPackageManager.swift`, so the tests should have the same local ownership before nearby Ruby behavior grows.

## Expected Behavior

- Future Bundler scanner or policy edits start in the dedicated suite.
- Agents can choose the narrow test owner without reading the larger package-policy suite first.
- No generated output, reason-code, or command-order behavior changes from this split alone.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later Bundler changes update `RubyBundlerPolicyTests.swift` directly.
- `PackageAndCommandPolicyTests.swift` stops accumulating Bundler-only cases.
- `swift test` and the test-annotation contract keep coverage executable.

## Failure Signals

- New Bundler cases are added back to `PackageAndCommandPolicyTests.swift`.
- The suite boundary causes duplicate fixtures or hides shared package-manager behavior.

## Result

Unjudged.
