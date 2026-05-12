---
type: nenrin_change
id: validation-claim-meta-discussion-filter
date: 2026-05-13
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/ProjectDetector.swift
  - Tests/HabitatCoreTests/InstructionAlignmentPolicyTests.swift
  - docs/current_status.md
  - docs/evaluation.md
review_after:
  tasks: 3
  days: 7
---

# Change: validation-claim-meta-discussion-filter

## Changed

- Filtered validation-command meta-discussion lines before creating sanitized `ValidationCommandClaim` values.
- Added instruction-alignment coverage for docs that mention covered Xcode cases and Gradle carry-back claims while still preserving a real SwiftPM validation instruction.

## Reason

Habitat's self-scan treated development-loop explanation text about prior Gradle and Xcode evidence as active local validation guidance. That produced false multi-workflow uncertainty in a SwiftPM repository and weakened the next command decision.

## Expected Behavior

- A SwiftPM self-scan can discuss prior Gradle/Xcode evidence in docs without losing the clear `swift test` validation hint.
- Real validation instructions still become sanitized claims when they are written as current project guidance.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later self-scans keep `Fact: Project instructions and repository files both support SwiftPM validation` when only meta-discussion mentions other workflows.
- External project scans still surface real project-local validation scripts or conflicting claims.

## Failure Signals

- A real instruction such as `Use xcodebuild test for local validation` is accidentally suppressed.
- The filter becomes a broad prose classifier instead of a small command-decision guard.

## Result

Unjudged.
