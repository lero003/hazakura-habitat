---
type: nenrin_change
id: carthage-build-artifact-family
date: 2026-05-11
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/PolicyReasonCatalog+ApplePackageManager.swift
  - Sources/HabitatCore/PolicyReasonCatalog+BaselinePolicy.swift
  - Sources/HabitatCore/PolicyReasonCatalog+PackageManagerReview.swift
  - Sources/HabitatCore/PolicyReasonCatalog+ReasonRules.swift
  - Tests/HabitatCoreTests/BaselineCommandCatalogTests.swift
  - Tests/HabitatCoreTests/PolicyReasonCatalogTests.swift
review_after:
  tasks: 3
  days: 7
---

# Change: carthage-build-artifact-family

## Changed

- Split `carthage build` out of `carthageDependencyMutationCommands` into `carthageBuildArtifactMutationCommands`.
- Kept Carthage Review First routing stable by composing dependency-mutation and build-artifact leaves.
- Added catalog and reason-classification coverage so `carthage build` remains Ask First with generic approval metadata.

## Reason

`carthage build` writes build artifacts and belongs behind approval, but the previous leaf made the generated reason text describe it as dependency install, update, or removal. That was a small overstatement in the AI-facing command-decision context.

## Expected Behavior

- Agents still pause before `carthage build`.
- The generated reason metadata no longer implies dependency mutation for that command.
- Future Carthage edits can update dependency-resolution and build-artifact commands separately.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- A later Carthage policy edit keeps Review First routing intact while touching the correct leaf.
- No generated-output or reason-code drift appears from this split.

## Failure Signals

- The extra family name adds review noise without clarifying future Carthage command decisions.
- Carthage Review First routing accidentally drops `carthage build`.
