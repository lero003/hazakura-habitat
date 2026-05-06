---
type: nenrin_change
id: swift-package-policy-test-boundary
date: 2026-05-07
status: observing
impact: unknown
related_files:
  - Tests/HabitatCoreTests/SwiftPackagePolicyTests.swift
  - Tests/HabitatCoreTests/PackageAndCommandPolicyTests.swift
  - docs/current_status.md
  - docs/roadmap.md
  - docs/self_use.md
review_after:
  tasks: 3
  days: 7
---

# Change: swift-package-policy-test-boundary

## Changed

- Split SwiftPM and Xcode command-selection scanner contracts out of `PackageAndCommandPolicyTests.swift` into `SwiftPackagePolicyTests.swift`.
- Kept generated output, scanner behavior, reason codes, command order, and policy rendering unchanged.

## Reason

SwiftPM and Xcode checks are a high-value command-decision boundary for Habitat self-use. Keeping those tests in a focused suite should make future Swift/Xcode policy changes easier to audit without growing the general package-policy test file.

## Expected Behavior

- Future SwiftPM or Xcode scanner changes start from `SwiftPackagePolicyTests.swift`.
- General package-manager test work does not need to read the Swift/Xcode scenario block first.
- Agents preserve no-output-change verification discipline for maintainability-only test boundary slices.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- A later Swift/Xcode policy or scanner edit uses the focused suite to choose and verify the right tests.
- A later package-manager edit avoids touching Swift/Xcode tests when unrelated.

## Failure Signals

- Swift/Xcode scenarios are duplicated back into the package-policy suite.
- Test ownership becomes unclear enough that command-selection regressions are missed.

## Result

Unjudged.
