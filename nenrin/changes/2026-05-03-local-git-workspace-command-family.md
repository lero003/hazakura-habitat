---
type: nenrin_change
id: local-git-workspace-command-family
date: 2026-05-03
status: reviewed
impact: effective
related_files:
  - Sources/HabitatCore/PolicyReasonCatalog.swift
  - Sources/HabitatCore/Scanner.swift
  - Tests/HabitatCoreTests/HabitatCoreTests.swift
  - docs/current_status.md
review_after:
  tasks: 3
  days: 7
---

# Change: local-git-workspace-command-family

## Changed

- Centralized local Git workspace/history/branch/remote mutation Ask First commands in `PolicyReasonCatalog`.
- Made scanner command generation consume the same command family used by `git_mutation` reason classification.

## Reason

The v0.3 self-use policy again routed Git/GitHub mutation review through `command_policy.md`. Reading that policy showed the local Git workspace list was still owned by scanner generation while reason classification used a broader Git/GitHub predicate. That made future Git command additions more likely to drift from their intended `git_mutation` reason.

## Expected Behavior

- Generated `command_policy.md` remains behaviorally unchanged for existing local Git mutation entries.
- Future local Git workspace/history/branch/remote mutation additions update one command family instead of drifting between scanner output and reason-code matching.
- Remote GitHub CLI actions continue to use `remote_repository_action`, while `gh pr checkout` and `gh repo clone` remain `git_mutation`.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later Git mutation additions attach to the centralized family without duplicated scanner and reason-catalog lists.
- Self-use policy review still asks before Git workspace, history, branch, worktree, remote, submodule, fetch, and push commands with local Git mutation reasoning.
- Generated output does not churn when internals are refactored.

## Failure Signals

- The family becomes a catch-all for remote repository actions that should keep `remote_repository_action`.
- Exact matching becomes too narrow and generated local Git commands fall back to `user_approval_required`.
- The full policy becomes harder to audit because local Git, remote GitHub, dependency, and archive risks are merged.

## Result

Reviewed on 2026-05-05: keep. The evidence shows the local Git command family changed publication behavior from broad staging to explicit policy review, verification, scoped diff inspection, explicit-file staging, commit, and push while preserving the remote repository boundary.
