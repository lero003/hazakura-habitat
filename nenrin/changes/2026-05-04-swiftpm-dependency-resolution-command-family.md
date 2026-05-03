---
type: nenrin_change
id: swiftpm-dependency-resolution-command-family
date: 2026-05-04
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/PolicyReasonCatalog.swift
  - Tests/HabitatCoreTests/HabitatCoreTests.swift
  - docs/current_status.md
review_after:
  tasks: 3
  days: 7
---

# Change: swiftpm-dependency-resolution-command-family

## Changed

- Added a catalog-owned SwiftPM dependency-resolution command family.
- Made selected package-manager review ordering and reason classification consume that same command family.
- Added focused coverage that the SwiftPM review commands still classify as `dependency_resolution_mutation`.

## Reason

The fresh v0.3 self-use report kept `swift package update` and `swift package resolve` visible as selected workflow mutations before broader package-manager policy. The previous review-map cleanup centralized their ordering, but reason classification still repeated the literal command strings. That created a small v0.4 maintainability drift risk.

## Expected Behavior

- Generated `agent_context.md`, `command_policy.md`, and `scan_result.json` remain unchanged.
- `swift package update` and `swift package resolve` keep the `dependency_resolution_mutation` reason code.
- Future SwiftPM dependency-resolution guard changes update one catalog family instead of separate review-ordering and reason-rule literals.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- SwiftPM self-use keeps dependency resolution behind Ask First while preserving `swift test` / `swift build` as preferred commands.
- Reason-code tests catch drift if a SwiftPM dependency-resolution command is added to review ordering but not classification.

## Failure Signals

- The family grows beyond dependency-resolution commands into broad SwiftPM ecosystem coverage.
- Generated output changes without a behavior-evaluation reason.

## Result

Unjudged.
