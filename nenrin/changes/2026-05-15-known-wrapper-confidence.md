---
type: nenrin_change
id: known-wrapper-confidence
date: 2026-05-15
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/DocumentedValidationCommandEvidence.swift
  - Tests/HabitatCoreTests/InstructionAlignmentPolicyTests.swift
  - Tests/HabitatCoreTests/CrossProjectBehaviorEvaluationTests.swift
  - examples/behavior-evaluation/project-local-validation-script-001.json
  - docs/evaluation.md
  - docs/current_status.md
review_after:
  tasks: 3
  days: 7
---

# Change: known-wrapper-confidence

## Changed

- Removed the generic wrapper-verification uncertainty from `agent_context.md`
  when a known executable project-local wrapper is already the only ordinary
  preferred command.

## Reason

Fresh ai-mobile intake showed the saved report was stale, while a fresh scan
correctly preferred only `./scripts/assemble-debug.sh`. Keeping the old generic
"verify whether the script wraps Gradle" line beside that decisive preference
created consumption friction without changing the next safe command.

## Expected Behavior

- Agents use the known wrapper directly when it is documented, executable, and
  already promoted to `Prefer`.
- Generic safe `./scripts/*.sh` claims still keep bounded uncertainty until a
  repeated command-decision trace justifies stronger confidence.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Future ai-mobile intake stays focused on `./scripts/assemble-debug.sh` as the
  ordinary validation command.
- Agents do not spend the first step re-verifying the same known wrapper before
  running local validation.
- Generic project-local scripts still tell agents to verify wrapper intent.

## Failure Signals

- Agents overgeneralize the known wrapper behavior to arbitrary scripts.
- Raw Gradle commands return as peer preferred commands for the known wrapper
  case.
- The short context becomes overconfident when the wrapper is missing or not
  executable.

## Result

Unjudged.
