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
  - examples/behavior-evaluation/cross-project-device-install-blocker-001.json
  - examples/README.md
  - docs/agent_contract.md
  - docs/current_status.md
  - docs/evaluation.md
review_after:
  tasks: 3
  days: 7
---

# Change: validation-command-purpose

## Changed

- Added a narrow validation-command `purpose` to sanitized instruction claims.
- Kept release/artifact scripts out of ordinary local validation preference while still recording them as `release_artifact` evidence.
- Added regression coverage proving `./scripts/build_release_artifacts.sh` is release-prep guidance, not the first everyday validation command.
- Extended the same purpose boundary for the observed connected-device script `./scripts/device-test.sh`, recording it as `device_verification` and keeping it out of ordinary local validation preference.

## Reason

Post-`v0.6` work needs distribution guidance without confusing `swift test`-style local validation with release artifact verification.

Post-`v0.7` cross-project intake also showed Android connected-device checks can sit near ordinary build commands while device install approval or host write blockers make them a poor default first command.

## Expected Behavior

- Agents and machine consumers can tell ordinary validation claims from release/artifact claims.
- Release-prep scripts stay visible as purpose-specific evidence without being promoted into `Prefer`.
- Connected-device verification scripts stay visible as purpose-specific evidence without being promoted into ordinary first-command validation.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Future reports keep `swift test` or the project-local everyday wrapper as the first validation command.
- Release artifact scripts remain visible only as release-prep or artifact-verification context.
- Device verification scripts remain visible only as connected-device check context.

## Failure Signals

- A release/package script appears in `policy.preferredCommands`.
- A connected-device script appears in `policy.preferredCommands` as the ordinary local validation command.
- Agents treat release artifact generation as the ordinary validation command for routine development.
- Agents treat device install or connected Android tests as the default first local validation command.

## Result

Unjudged.
