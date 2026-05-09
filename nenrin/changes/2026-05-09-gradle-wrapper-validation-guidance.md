---
type: nenrin_change
id: gradle-wrapper-validation-guidance
date: 2026-05-09
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/ProjectDetector.swift
  - Sources/HabitatCore/Scanner.swift
  - Sources/HabitatCore/DocumentedValidationCommandEvidence.swift
  - Sources/HabitatCore/ReportWriter.swift
  - Tests/HabitatCoreTests/GradlePolicyTests.swift
  - examples/behavior-evaluation/gradle-wrapper-validation-001.json
  - docs/current_status.md
  - docs/development_loop.md
  - docs/evaluation.md
  - docs/roadmap.md
review_after:
  tasks: 3
  days: 7
---

# Change: gradle-wrapper-validation-guidance

## Changed

- Added a bounded executable `gradlew` project signal that can select Gradle wrapper validation and align sanitized `./gradlew test` claims with repository facts.

## Reason

The cross-project self-use observation showed a real command-decision gap: Habitat stayed at generic read-only inspection even when a project-local Gradle wrapper and documented smoke check were visible.

## Expected Behavior

- Future Gradle-wrapper repositories move agents toward project-local `./gradlew test` / `./gradlew build` guidance without assuming global Gradle or expanding into Android environment auditing.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Agents use executable wrapper facts before broad project search when Gradle wrapper validation is present.
- Later work resists adding Android-specific checks without a measured command mistake.

## Failure Signals

- Agents still treat executable Gradle wrapper projects as no-primary-package-manager repositories.
- The slice grows into global Gradle or Android environment assumptions without new behavior evidence.

## Result

Unjudged.
