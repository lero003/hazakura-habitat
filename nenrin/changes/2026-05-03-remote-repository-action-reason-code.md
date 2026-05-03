---
type: nenrin_change
id: remote-repository-action-reason-code
date: 2026-05-03
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/PolicyReasonCatalog.swift
  - Tests/HabitatCoreTests/HabitatCoreTests.swift
  - docs/agent_contract.md
  - docs/current_status.md
  - docs/self_use.md
review_after:
  tasks: 3
  days: 7
---

# Change: remote-repository-action-reason-code

## Changed

- Added a `remote_repository_action` reason family for GitHub CLI commands that act on remote repository metadata, CI state, releases, variables, secrets, reviews, comments, or API content.
- Kept local checkout and clone commands such as `gh pr checkout` and `gh repo clone` under `git_mutation`.

## Reason

The v0.3 self-use policy review requires reading the full command policy before Git/GitHub mutations. That policy labeled every `gh` Ask First command as `git_mutation`, which was precise for local checkout/clone commands but misleading for remote PR review, workflow, release, secret, variable, and API actions.

## Expected Behavior

- Agents still ask before risky GitHub CLI commands.
- Agents can distinguish local Git workspace/history risk from remote GitHub repository action risk while reviewing `command_policy.md` or `scan_result.json`.
- Future GitHub CLI policy additions can use the reason catalog instead of duplicating renderer-specific wording.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Agents explain `gh workflow run`, `gh release upload`, `gh variable get`, or `gh api` as remote repository actions.
- Local checkout and clone guidance continues to mention Git workspace mutation.
- The added reason family improves long-policy clarity without changing the short context budget.

## Failure Signals

- The reason family becomes a catch-all for unrelated remote services.
- Agents treat `remote_repository_action` as safer than Ask First instead of as a clearer approval reason.
- Short-context overflow becomes noisier without changing policy-review behavior.

## Result

Unjudged.
