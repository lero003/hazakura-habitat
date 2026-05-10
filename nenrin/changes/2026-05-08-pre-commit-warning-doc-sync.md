---
type: nenrin_change
id: pre-commit-warning-doc-sync
date: 2026-05-08
status: observing
impact: unknown
related_files:
  - CHANGELOG.md
  - docs/current_status.md
  - docs/roadmap.md
  - docs/self_use.md
  - Sources/HabitatCore/ReportWriter.swift
  - Tests/HabitatCoreTests/PreCommitPolicyTests.swift
review_after:
  tasks: 3
  days: 7
---

# Change: pre-commit-warning-doc-sync

## Changed

- Documented the existing pre-commit configuration warning as an agent-facing command-decision boundary.
- Recorded `PreCommitPolicyTests.swift` as the ownership point for hook-related `agent_context.md` guidance.
- Tightened the generated warning from a generic `git status` reminder to the read-only `git status --short` check.

## Reason

Commit hooks can mutate the workspace after an otherwise normal Git commit. Agents need a small reminder to check the workspace after hooks run, without broadening the Git mutation policy or treating symlinked hook configs as trusted local behavior. Naming `git status --short` keeps the next command concrete and read-only.

## Expected Behavior

- Future pre-commit warning changes update tests and docs together.
- Agents treat hook presence as a post-commit verification cue rather than a reason to avoid normal local validation.
- Agents choose a narrow status check after hooks instead of broad Git review or workspace mutation.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later Git or hook-related work preserves the post-hook `git status` cue.
- Generated context continues to name a read-only status command after pre-commit hooks.
- Symlinked `.pre-commit-config.yaml` stays out of the warning unless a measured command-decision problem justifies changing it.

## Failure Signals

- The warning becomes noisy in repositories where hooks are irrelevant.
- Agents treat pre-commit presence as a blocker instead of a verification reminder.

## Result

Unjudged.
