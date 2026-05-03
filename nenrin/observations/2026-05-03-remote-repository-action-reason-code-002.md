---
type: nenrin_observation
id: remote-repository-action-reason-code-002
date: 2026-05-03
related_changes:
  - remote-repository-action-reason-code
impact_judgment: effective
success_tags:
  - boundary_preserved
  - cleanup_choice_improved
failure_tags: []
---

# Observation: remote-repository-action-reason-code-002

## Task

Post-v0.3 self-use automation slice for v0.4 policy-engine hardening.

## Observed Behavior

- The refreshed Habitat context kept Git/GitHub mutation behind `command_policy.md` review.
- Reviewing that policy showed the earlier local-vs-remote GitHub CLI split was still useful: `gh pr checkout` and `gh repo clone` need local Git mutation reasoning, while PR review, workflow, release, secret, variable, and API actions need remote repository-action reasoning.
- That boundary shaped the cleanup: only local Git workspace commands moved into a new centralized family, while remote GitHub CLI actions stayed in the existing remote action family.

## Success Signals Observed

- The next implementation preserved the `remote_repository_action` boundary instead of merging all GitHub-related commands into `git_mutation`.
- The cleanup removed duplicated local Git mutation ownership without changing generated command-policy behavior.
- Focused tests now assert the local Git family keeps `git_mutation` while remote GitHub CLI commands keep `remote_repository_action`.

## Failure Signals Observed

- None observed in this slice.

## Impact Judgment

effective

## Next Action

- Keep local Git and remote GitHub action families separate; only add commands where the next command decision needs that distinction.
