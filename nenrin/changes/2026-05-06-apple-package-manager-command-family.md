---
type: nenrin_change
id: apple-package-manager-command-family
date: 2026-05-06
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/PolicyReasonCatalog+ApplePackageManager.swift
  - Sources/HabitatCore/PolicyReasonCatalog.swift
  - Sources/HabitatCore/Scanner.swift
  - Tests/HabitatCoreTests/PackageAndCommandPolicyTests.swift
  - docs/current_status.md
review_after:
  tasks: 3
  days: 7
---

# Change: apple-package-manager-command-family

## Changed

- Centralized CocoaPods, Carthage, and Xcodebuild command arrays in `PolicyReasonCatalog`.
- Made scanner Ask First command generation and selected Apple package-manager review ordering consume catalog-owned arrays.
- Added catalog classification coverage so CocoaPods and Carthage commands keep their current reason codes while Xcodebuild project-mutation guards keep generic approval classification.

## Reason

The post-v0.4 self-scan still showed long command-policy output as active command-decision context. CocoaPods, Carthage, and Xcodebuild were small remaining scanner-local package-manager families, which made future Apple workflow policy edits easier to drift from catalog-owned review ordering.

## Expected Behavior

- Generated command lists and ordering remain unchanged for existing fixtures.
- `pod install`, `pod update`, and `pod repo update` keep `dependency_mutation`; `pod deintegrate` keeps generic approval classification.
- `carthage bootstrap`, `carthage update`, `carthage checkout`, and `carthage build` keep `dependency_mutation`.
- Xcodebuild scheme-selection, dependency-resolution, and provisioning guards keep generic approval classification.
- Future Apple workflow policy edits have one command-family owner for scanner generation and review ordering.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Apple workflow command reasons do not regress unexpectedly.
- Future CocoaPods, Carthage, or Xcodebuild policy changes reuse catalog-owned arrays instead of scanner-local duplicates.
- Generated policy counts stay stable unless a behavior-driven command addition intentionally changes them.

## Failure Signals

- Generated Ask First ordering changes unexpectedly.
- Apple workflow policy broadens into ecosystem inventory without observed command-decision need.
- Selected review ordering diverges from the full command policy.

## Result

Unjudged.
