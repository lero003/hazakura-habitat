---
type: nenrin_change
id: project-local-validation-script-boundary
date: 2026-05-13
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/ProjectLocalValidationScript.swift
  - Sources/HabitatCore/DocumentedValidationCommandEvidence.swift
  - Sources/HabitatCore/ProjectDetector.swift
  - Sources/HabitatCore/ReportWriter.swift
  - Tests/HabitatCoreTests/InstructionAlignmentPolicyTests.swift
  - docs/current_status.md
  - docs/roadmap.md
review_after:
  tasks: 3
  days: 7
---

# Change: project-local-validation-script-boundary

## Changed

- Added a shared ProjectLocalValidationScript boundary and a regression test proving missing project-local validation scripts are not promoted into short Prefer output.

## Reason

Project-local validation script guidance now affects cross-project command choice, so script recognition and executable promotion should not drift across detector, evidence, and renderer code.

## Expected Behavior

- Agents still see bounded project-local script uncertainty, but only executable project-local scripts are promoted ahead of raw package-manager commands.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Future project-local validation script edits update `ProjectLocalValidationScript` instead of drifting across detector, evidence, and renderer code.
- Missing or non-executable script claims keep bounded uncertainty but do not displace executable package-manager validation commands in short `Prefer` output.

## Failure Signals

- A future script claim is recognized in one output path but not another.
- Agents are told to prefer a project-local validation script that does not exist or is not executable.

## Result

Unjudged.
