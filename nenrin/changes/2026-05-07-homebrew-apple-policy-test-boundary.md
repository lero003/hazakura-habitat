---
type: nenrin_change
id: homebrew-apple-policy-test-boundary
date: 2026-05-07
status: observing
impact: unknown
related_files:
  - Tests/HabitatCoreTests/HomebrewApplePolicyTests.swift
  - Tests/HabitatCoreTests/PackageAndCommandPolicyTests.swift
review_after:
  tasks: 3
  days: 7
---

# Change: homebrew-apple-policy-test-boundary

## Changed

- Split Homebrew Bundle, Homebrew host-state, CocoaPods, and Carthage scanner policy scenarios into `HomebrewApplePolicyTests.swift`.
- Kept generated policy behavior unchanged while reducing `PackageAndCommandPolicyTests.swift`.

## Reason

Homebrew and Apple package-manager command families already have catalog-owned boundaries. Their scanner contracts should have the same local test owner so future `brew`, CocoaPods, or Carthage edits can be verified without searching the larger package-policy suite.

## Expected Behavior

- Future Homebrew, CocoaPods, and Carthage scanner or policy edits start in the dedicated suite.
- Agents can choose the narrow test owner for Apple package-manager command decisions.
- No generated output, reason-code, or command-order behavior changes from this split alone.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later Homebrew or Apple package-manager changes update `HomebrewApplePolicyTests.swift` directly.
- `PackageAndCommandPolicyTests.swift` stops accumulating Homebrew/CocoaPods/Carthage-only cases.
- `swift test` and the test-annotation contract keep coverage executable.

## Failure Signals

- New Homebrew, CocoaPods, or Carthage cases are added back to `PackageAndCommandPolicyTests.swift`.
- The suite boundary causes duplicate fixtures or hides shared package-manager behavior.

## Result

Unjudged.
