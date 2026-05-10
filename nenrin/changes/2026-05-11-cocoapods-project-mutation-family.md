---
type: nenrin_change
id: cocoapods-project-mutation-family
date: 2026-05-11
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/PolicyReasonCatalog+ApplePackageManager.swift
  - Sources/HabitatCore/PolicyReasonCatalog+BaselinePolicy.swift
  - Sources/HabitatCore/PolicyReasonCatalog+PackageManagerReview.swift
  - Tests/HabitatCoreTests/BaselineCommandCatalogTests.swift
  - Tests/HabitatCoreTests/PolicyReasonCatalogTests.swift
review_after:
  tasks: 3
  days: 7
---

# Change: cocoapods-project-mutation-family

## Changed

- Split `pod deintegrate` out of `cocoapodsDependencyMutationCommands` into `cocoapodsProjectMutationCommands`.
- Kept CocoaPods Review First routing and rendered baseline Ask First order stable through `cocoapodsPackageManagerReviewCommands`.
- Updated catalog manifest and reason-classification tests to keep the new leaf family explicit.

## Reason

`pod deintegrate` already kept generic approval metadata, but it lived inside a dependency-mutation-named command family. That made the catalog ownership boundary less honest and required tests to special-case the command by literal string.

## Expected Behavior

- Generated policy output remains unchanged.
- Future CocoaPods edits can distinguish dependency-resolution mutations from project mutation review entries.
- Manifest classification tests explain the generic approval case through a named leaf family instead of a hidden literal exception.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- A later CocoaPods policy edit can update the correct family without rereading broad Apple package-manager code.
- No generated-output or reason-code drift appears from this split.

## Failure Signals

- The extra family name adds review noise without clarifying future CocoaPods command decisions.
- CocoaPods Review First routing accidentally drops `pod deintegrate`.

## Result

Unjudged.
