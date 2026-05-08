---
type: nenrin_change
id: xcodebuild-validation-claim-scheme-discovery
date: 2026-05-08
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/ProjectDetector.swift
  - Sources/HabitatCore/DocumentedValidationCommandEvidence.swift
  - Tests/HabitatCoreTests/InstructionAlignmentPolicyTests.swift
  - examples/behavior-evaluation/instruction-claim-xcodebuild-001.json
  - CHANGELOG.md
  - docs/development_loop.md
  - docs/evaluation.md
  - docs/current_status.md
  - docs/roadmap.md
  - docs/self_use.md
review_after:
  tasks: 3
  days: 7
---

# Change: xcodebuild-validation-claim-scheme-discovery

## Changed

- Added `xcodebuild test` to sanitized documented validation-command extraction.
- Changed documented Xcode validation evidence so matching Xcode project facts constrain the first command to `xcodebuild -list` before following a scheme-dependent documented test command.
- Added an instruction-alignment test and behavior-evaluation fixture for the Xcode scheme-discovery command decision.

## Reason

The post-`v0.5` handoff left one narrow Xcode validation-claim case. A documented `xcodebuild test` claim should not be ignored, but it also should not cause an agent to run a scheme-dependent command before discovering available schemes. The safer command decision is to preserve the claim as evidence while starting with repository-supported Xcode discovery.

## Expected Behavior

- Agents treat documented `xcodebuild test` as Xcode validation evidence when repository facts select Xcode.
- Agents start with generated `xcodebuild -list` guidance before running scheme-dependent validation.
- Raw instruction prose stays out of generated artifacts and behavior fixtures.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Future Xcode tasks use scheme discovery before documented test commands when no scheme is selected.
- Instruction-alignment follow-ups remain local to command-changing validation claims.

## Failure Signals

- Agents treat the hint as permission to run `xcodebuild test` immediately.
- Xcode instruction alignment grows into broad prose parsing instead of bounded command evidence.

## Result

Unjudged.
