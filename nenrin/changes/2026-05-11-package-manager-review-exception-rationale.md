---
type: nenrin_change
id: package-manager-review-exception-rationale
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

# Change: package-manager-review-exception-rationale

## Changed

- Replaced the raw package-manager Review First exception string with a typed exception entry.
- Added a required rationale for the Gradle exception.
- Tightened the catalog test so exceptions must stay unique and explain why they are unrouted.

## Reason

Gradle wrapper support currently changes local validation-command selection, not dependency-mutation review guidance. Keeping the exception reason in the catalog prevents future maintainers from treating an unrouted package manager as an accidental gap or as broad Gradle coverage.

## Expected Behavior

- Generated policy output, command order, reason codes, Markdown, and JSON stay unchanged.
- Future Review First route exceptions must explain the command-decision boundary before landing.
- Gradle remains bounded to executable wrapper validation until behavior evidence justifies broader mutation guidance.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- A later package-manager route or exception edit updates the rationale deliberately.
- No automation treats the Gradle exception as broad dependency-mutation coverage.

## Failure Signals

- Exception rationales become boilerplate and stop changing review behavior.
- Agents need Gradle dependency-mutation guidance and the exception hides that missing coverage.

## Result

Unjudged.
