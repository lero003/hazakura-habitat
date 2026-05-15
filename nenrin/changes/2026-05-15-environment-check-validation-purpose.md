---
type: nenrin_change
id: environment-check-validation-purpose
date: 2026-05-15
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/Models.swift
  - Sources/HabitatCore/ProjectDetector.swift
  - Sources/HabitatCore/ProjectLocalValidationScript.swift
  - Sources/HabitatCore/DocumentedValidationCommandEvidence.swift
  - Tests/HabitatCoreTests/InstructionAlignmentPolicyTests.swift
  - docs/current_status.md
  - docs/evaluation.md
review_after:
  tasks: 3
  days: 7
---

# Change: environment-check-validation-purpose

## Changed

- Added a narrow `environment_check` validation-command purpose for the
  observed `./scripts/dev-env-check.sh` preflight script.
- Kept environment preflight checks out of ordinary local validation preference
  while preserving the real project-local validation wrapper as the preferred
  command.

## Reason

Cross-project intake found that ai-mobile documents `./scripts/dev-env-check.sh`
near `./scripts/assemble-debug.sh`. Treating both as ordinary local validation
can confuse machine consumers and future ordering changes, even though only the
assemble wrapper should drive the first validation command.

## Expected Behavior

- Habitat records `./scripts/dev-env-check.sh` as setup/preflight context, not
  ordinary local validation.
- Agents still prefer `./scripts/assemble-debug.sh` for local validation.
- The distinction stays limited to this observed command until more evidence
  justifies broader setup/lint/smoke taxonomy.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Future ai-mobile intake keeps environment checks separate from validation
  commands.
- No broad validation-purpose taxonomy is added from a single setup script.

## Failure Signals

- Agents start running environment preflight as the main validation command.
- More one-off script purposes accumulate without repeated command-decision
  evidence.

## Result

Unjudged.
