---
type: nenrin_change
id: post-v0-5-review-automation-guidance
date: 2026-05-08
status: observing
impact: unknown
related_files:
  - docs/current_status.md
  - docs/development_loop.md
  - docs/roadmap.md
  - docs/evaluation.md
  - docs/github_workflow.md
  - CHANGELOG.md
review_after:
  tasks: 3
  days: 7
---

# Change: post-v0-5-review-automation-guidance

## Changed

- Recorded that post-release review found no `v0.5.0` rollback, hotfix, or release-note correction need.
- Added automation-facing next-slice guidance for instruction-alignment follow-ups: multiple claims, unknown repository workflow, negated/obsolete commands, and Xcode validation claims.
- Added future release-process guidance to verify release artifacts before pushing public version tags when practical.

## Reason

The review validated the public `v0.5.0 Developer Preview` state and identified useful follow-ups that should not be confused with patch-release blockers. Automation needs that distinction in docs so it does not spend cycles re-litigating the release or broaden instruction alignment into a prose linter.

## Expected Behavior

- Post-`v0.5` automation treats the release as accepted unless a published artifact or install instruction is materially wrong.
- If automation chooses instruction-alignment work, it picks one narrow command-changing case rather than a broad parser.
- Future release automation verifies local and workflow artifacts before public tags when practical, and uses patch releases instead of retargeting public releases.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- The next automation run starts from post-`v0.5` observation instead of rollback or hotfix work.
- Instruction-alignment follow-up stays scoped to one fixture and one command decision.
- Release-prep work checks artifacts before the public tag path.

## Failure Signals

- Automation treats non-blocking review notes as a release patch.
- Automation starts a generic instruction-prose parser.
- A future release repeats tag-path artifact failure without a pre-tag artifact check.

## Result

Unjudged.
