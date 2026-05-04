---
type: nenrin_review
id: review-remote-repository-action-reason-code
date: 2026-05-04
related_change: remote-repository-action-reason-code
final_judgment: keep
---

# Review: remote-repository-action-reason-code

## Summary

Keep the remote repository action reason family as a distinct GitHub CLI policy boundary.

## Evidence

- Three related observations reached the review threshold.
- Later work used the boundary to keep `gh pr checkout` and `gh repo clone` under local Git mutation reasoning while remote PR, workflow, release, secret, variable, and API actions stayed under remote repository action reasoning.
- The next cleanup choice narrowed to centralizing local Git workspace commands instead of collapsing all GitHub CLI commands into one `git_mutation` family.
- Focused tests preserved the local Git and remote repository action split without changing generated policy output.

## Decision

- keep

## Cleanup

- Mark the change reviewed and effective.
- Keep using this reason only for GitHub CLI actions whose risk is remote repository state or metadata, not local checkout or clone behavior.
- Continue watching that agents do not treat the clearer reason as lower risk than Ask First.
