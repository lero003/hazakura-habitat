---
type: nenrin_change
id: generic-project-local-validation-script
date: 2026-05-13
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/ProjectLocalValidationScript.swift
  - Sources/HabitatCore/ProjectDetector.swift
  - Tests/HabitatCoreTests/InstructionAlignmentPolicyTests.swift
  - examples/behavior-evaluation/project-local-validation-script-generic-001.json
review_after:
  tasks: 3
  days: 7
---

# Change: generic-project-local-validation-script

## Changed

- Generalized project-local validation script detection from one known external script name to bounded safe `./scripts/*.sh` claims in validation context.
- Kept existing safety boundaries: parent-directory paths and non-shell script examples are ignored, and scripts are promoted into `Prefer` only when executable in the project.

## Reason

The external ai-mobile intake confirmed that project-local validation wrappers are a real command-decision boundary. Hardcoding only the first observed script name would make the boundary too brittle for other projects with the same shape.

## Expected Behavior

- Agents see the documented project-local script before raw package-manager validation when the script exists.
- Agents still verify whether the script wraps the selected package manager before using raw commands.
- Habitat does not expand into broad Android or arbitrary script auditing.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Future project-local wrapper cases reuse the generic `./scripts/*.sh` path without adding one-off script names.
- No raw instruction prose, unsafe parent paths, or non-shell examples appear as validation claims.

## Failure Signals

- Agents bypass documented validation wrappers because Habitat misses common safe script shapes.
- The extractor starts accepting arbitrary scripts or paths outside `./scripts/`.

## Result

Unjudged.
