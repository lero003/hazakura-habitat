---
type: nenrin_change
id: gradle-wrapper-script-preference
date: 2026-05-15
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/ReportWriter.swift
  - Tests/HabitatCoreTests/InstructionAlignmentPolicyTests.swift
  - Tests/HabitatCoreTests/ScanComparisonTests.swift
  - docs/current_status.md
review_after:
  tasks: 3
  days: 7
---

# Change: gradle-wrapper-script-preference

## Changed

- Replaced raw Gradle validation preferences with the project-local assemble-debug script when that executable script is documented and available.

## Reason

Fresh ai-mobile intake showed current docs route validation through HAZAKURA_GRADLE_TASK and ./scripts/assemble-debug.sh, while Habitat still left raw ./gradlew test in Prefer.

## Expected Behavior

- Agents use the documented wrapper as the local validation entrypoint before reaching for raw Gradle commands.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Future ai-mobile intake shows `./scripts/assemble-debug.sh` as the only preferred ordinary validation command.
- Agents do not choose raw `./gradlew test` before the documented wrapper when the wrapper is available.
- Generic safe project-local validation scripts still preserve raw package-manager fallback unless later evidence justifies replacing it.

## Failure Signals

- Raw Gradle validation reappears beside `./scripts/assemble-debug.sh` in preferred output for the observed wrapper case.
- The special case expands into broad Android or Gradle task taxonomy without another command-decision trace.
- A missing or non-executable wrapper suppresses otherwise useful Gradle validation guidance.

## Result

Unjudged.
