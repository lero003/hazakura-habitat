---
type: nenrin_change
id: project-local-validation-script-uncertainty
date: 2026-05-12
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/ProjectDetector.swift
  - Sources/HabitatCore/DocumentedValidationCommandEvidence.swift
  - Tests/HabitatCoreTests/InstructionAlignmentPolicyTests.swift
  - docs/current_status.md
  - docs/evaluation.md
review_after:
  tasks: 3
  days: 7
---

# Change: project-local-validation-script-uncertainty

## Changed

- Added a bounded instruction-alignment case for project-local validation scripts such as `./scripts/assemble-debug.sh`.
- Habitat now records the sanitized script command from development guidance and emits `Open uncertainty` before agents use raw package-manager validation commands.

## Reason

The `hazakura-ai-mobile` intake showed repository facts selecting Gradle wrapper validation while development docs route validation through a repo script. That should change the next command from simply running raw `./gradlew` toward verifying whether the script is the intended entrypoint.

## Expected Behavior

- Agents notice project-local validation scripts in development guidance without storing raw prose.
- Agents verify whether the script wraps the selected package manager before using raw package-manager commands.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Future cross-project intakes use this uncertainty to choose repo scripts when docs make them the validation entrypoint.
- The case stays bounded to command-changing validation guidance and does not become a broad prose parser.

## Failure Signals

- Agents still default to raw package-manager commands when development guidance clearly routes validation through a script.
- Script detection starts surfacing noisy non-validation examples.

## Result

Unjudged.
