---
type: nenrin_change
id: documented-validation-command-evidence
date: 2026-05-08
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/DocumentedValidationCommandEvidence.swift
  - Sources/HabitatCore/ProjectDetector.swift
  - Sources/HabitatCore/ReportWriter.swift
  - Tests/HabitatCoreTests/InstructionAlignmentPolicyTests.swift
  - docs/evaluation.md
  - examples/behavior-evaluation/instruction-claim-validation-001.json
review_after:
  tasks: 3
  days: 7
---

# Change: documented-validation-command-evidence

## Changed

- Added sanitized `ValidationCommandClaim` data for allowlisted instruction files.
- Added `DocumentedValidationCommandEvidence` so `agent_context.md` can compare documented validation-command claims with repository facts.
- Added focused tests for conflicting and matching claims, including raw-prose non-emission.
- Added the first instruction-claim behavior fixture for the `v0.5.0 Developer Preview` release.

## Reason

The `v0.5` release name includes Instruction Alignment. Secret-bearing evidence alone was a good evidence slice, but the release needed one narrow case where project instructions and repository facts affect the next command. Validation commands are the smallest useful case because the output can change or confirm `swift test` versus a documented package-manager command without parsing general prose.

## Expected Behavior

- Agents prefer the repository-supported validation command when a documented validation command conflicts with package-manager facts.
- Agents can see a short `Fact`, `Warning`, and `Hint` in `agent_context.md` without seeing raw instruction prose.
- Future instruction-alignment work stays narrow until another measured command-decision case exists.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- A later self-use or fixture trace shows an agent avoiding an unsupported documented validation command.
- `agent_context.md` remains short when validation-command claims are present.
- No future slice expands this into a generic instruction parser without a command-changing case.

## Failure Signals

- Agents still trust stale documented validation commands over repository facts.
- Raw instruction prose appears in generated artifacts or behavior fixtures.
- Instruction-alignment work grows into broad prose linting before another measured case exists.

## Result

Unjudged.
