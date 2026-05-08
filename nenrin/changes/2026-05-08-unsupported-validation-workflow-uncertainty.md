---
type: nenrin_change
id: unsupported-validation-workflow-uncertainty
date: 2026-05-08
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/DocumentedValidationCommandEvidence.swift
  - Tests/HabitatCoreTests/InstructionAlignmentPolicyTests.swift
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

# Change: unsupported-validation-workflow-uncertainty

## Changed

- Changed documented validation-command evidence so a documented workflow with no repository-supported workflow emits bounded `Open uncertainty`.
- Added an instruction-alignment test proving `Run npm test before committing changes.` in a repository with no package-manager facts avoids a confident mismatch warning.

## Reason

The post-`v0.5` handoff named unsupported documented workflows as a small instruction-alignment risk. When repository facts cannot identify a primary validation workflow, Habitat should not pretend the documented command is wrong or right. The safer command decision is to pause and verify before running the documented validation command.

## Expected Behavior

- Agents do not treat unsupported documented validation commands as confirmed local workflows.
- Agents also do not get a false conflict warning that claims repository facts selected an unknown workflow.
- Raw instruction prose stays out of generated artifacts.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Future instruction-alignment slices keep uncertainty bounded when repository facts are insufficient.
- Agents verify documented validation commands before running them in repositories with weak workflow signals.

## Failure Signals

- Too many repositories with legitimate documented workflows lose useful guidance.
- `Open uncertainty` becomes a vague fallback instead of a command-changing stop point.

## Result

Unjudged.
