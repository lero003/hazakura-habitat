---
type: nenrin_change
id: v0-5-instruction-alignment-release-gate
date: 2026-05-08
status: observing
impact: unknown
related_files:
  - docs/roadmap.md
  - docs/current_status.md
  - docs/development_loop.md
  - docs/evaluation.md
  - CHANGELOG.md
review_after:
  tasks: 3
  days: 7
---

# Change: v0-5-instruction-alignment-release-gate

## Changed

- Documented that `v0.5.0 Developer Preview` is the natural next release target, but should wait for one instruction-alignment slice before the version bump.
- Narrowed that slice to documented validation-command claims checked against repository facts.
- Added an evaluation case for instruction claims versus repo facts, with raw instruction prose kept out of generated artifacts and fixtures.
- Added a release handoff checklist that keeps `generatorVersion`, README status, examples, changelog, release notes, and generated artifacts aligned.

## Reason

External release-readiness feedback agreed that the current post-`v0.4.0` work is more than a patch because maintainability splits, policy catalog boundaries, contract tests, and `SecretBearingEvidence` have landed. The remaining risk is product-claim mismatch: `v0.5` is named Evidence and Instruction Alignment, but the implemented evidence slice is stronger than the instruction-alignment proof.

## Expected Behavior

- The next development slice focuses on one small instruction-alignment case instead of broad architecture or release ceremony.
- Agents do not bump `HabitatMetadata.generatorVersion` to `0.5.0` until the documented-validation-command case exists and changes, confirms, or constrains a next command.
- Release notes can explain the AI-first command-decision impact rather than only listing internal test and catalog cleanup.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- A later fixture or self-use trace shows Habitat checking a documented validation command against repository facts.
- Generated output uses short `Fact`, `Warning`, or `Hint` annotations without quoting raw project prose.
- The `v0.5.0` release checklist is easier to execute because version, docs, examples, changelog, release notes, and artifacts have an explicit alignment gate.

## Failure Signals

- The next slice expands into a generic instruction parser or prose linter.
- `0.5.0` is bumped before an instruction-alignment command-decision case exists.
- Release notes describe only internal maintainability work and do not explain how the agent's next command changes.

## Result

Unjudged.
