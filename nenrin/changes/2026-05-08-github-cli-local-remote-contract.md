---
type: nenrin_change
id: github-cli-local-remote-contract
date: 2026-05-08
status: observing
impact: unknown
related_files:
  - Tests/HabitatCoreTests/PolicyReasonCatalogTests.swift
  - CHANGELOG.md
  - docs/current_status.md
  - docs/roadmap.md
  - docs/self_use.md
review_after:
  tasks: 3
  days: 7
---

# Change: github-cli-local-remote-contract

## Changed

- Added a PolicyReasonCatalogTests contract that checks every GitHub CLI mutation command keeps the intended local-workspace or remote-repository reason code.

## Reason

GitHub CLI policy is command-decision sensitive: checkout and clone mutate the local workspace, while PR, issue, workflow, release, secret, variable, and API commands act on remote repository state. A future command addition should not collapse those risks into one reason family.

## Expected Behavior

- Future GitHub CLI catalog edits fail fast when a command lands in the wrong reason family, preserving clearer command_policy.md and scan_result.json reason metadata without changing generated output.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- A later GitHub CLI policy edit adds commands without collapsing checkout/clone into remote action reasoning or remote actions into local Git mutation reasoning.
- `command_policy.md` and `scan_result.json` continue to explain GitHub CLI risk with the specific local or remote reason family.

## Failure Signals

- The contract becomes a hand-maintained allowlist that blocks an intentional new local GitHub CLI command shape without helping command decisions.
- Agents still need to inspect unrelated policy text to distinguish local workspace mutation from remote repository action risk.

## Result

Unjudged.
