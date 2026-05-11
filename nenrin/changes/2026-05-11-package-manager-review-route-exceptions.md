---
type: nenrin_change
id: package-manager-review-route-exceptions
date: 2026-05-11
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/PolicyReasonCatalog+PackageManagerReview.swift
  - Tests/HabitatCoreTests/PolicyReasonCatalogTests.swift
  - docs/current_status.md
  - docs/roadmap.md
  - docs/self_use.md
review_after:
  tasks: 3
  days: 7
---

# Change: package-manager-review-route-exceptions

## Changed

- Added an explicit package-manager Review First route exception list.
- Kept `gradle` unrouted for mutation review while preserving executable wrapper validation guidance.
- Added a contract that detected package-manager identifiers either route Review First commands or appear in the explicit exception list.

## Reason

Gradle wrapper support currently changes validation-command selection, not dependency-mutation guidance. Leaving `gradle` as an implicit missing Review First route would make future package-manager drift harder to review.

## Expected Behavior

- Agents can still prefer `./gradlew test` and `./gradlew build` when an executable wrapper is present.
- Habitat does not imply deeper Gradle dependency-mutation coverage without observed command-changing evidence.
- Future detected package-manager identifiers must make their Review First boundary explicit.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- A later package-manager addition updates either Review First routing or the exception list deliberately.
- No automation treats executable Gradle wrapper validation as broad Gradle or Android policy coverage.

## Failure Signals

- The exception list becomes a dumping ground for unreviewed ecosystem coverage.
- Agents need Gradle dependency-mutation guidance and the explicit exception hides that gap.
