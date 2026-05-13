---
type: nenrin_change
id: validation-command-purpose
date: 2026-05-13
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/Models.swift
  - Sources/HabitatCore/ProjectDetector.swift
  - Sources/HabitatCore/ProjectLocalValidationScript.swift
  - Sources/HabitatCore/DocumentedValidationCommandEvidence.swift
  - Sources/HabitatCore/ReportWriter.swift
  - Tests/HabitatCoreTests/InstructionAlignmentPolicyTests.swift
  - docs/agent_contract.md
  - docs/current_status.md
review_after:
  tasks: 3
  days: 7
---

# Change: validation-command-purpose

## Changed

- Added a narrow validation-command `purpose` to sanitized instruction claims.
- Kept release/artifact scripts out of ordinary local validation preference while still recording them as `release_artifact` evidence.
- Added regression coverage proving `./scripts/build_release_artifacts.sh` is release-prep guidance, not the first everyday validation command.

## Reason

Post-`v0.6` work needs distribution guidance without confusing `swift test`-style local validation with release artifact verification.

## Expected Behavior

- Agents and machine consumers can tell ordinary validation claims from release/artifact claims.
- Release-prep scripts stay visible as purpose-specific evidence without being promoted into `Prefer`.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Future reports keep `swift test` or the project-local everyday wrapper as the first validation command.
- Release artifact scripts remain visible only as release-prep or artifact-verification context.

## Failure Signals

- A release/package script appears in `policy.preferredCommands`.
- Agents treat release artifact generation as the ordinary validation command for routine development.

## Result

Unjudged.
