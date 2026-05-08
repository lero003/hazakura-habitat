---
type: nenrin_change
id: command-policy-reason-line-sync-contract
date: 2026-05-08
status: observing
impact: unknown
related_files:
  - Tests/HabitatCoreTests/PolicyOutputContractTests.swift
  - CHANGELOG.md
  - docs/current_status.md
  - docs/roadmap.md
  - docs/self_use.md
review_after:
  tasks: 3
  days: 7
---

# Change: command-policy-reason-line-sync-contract

## Changed

- Added an output-contract test proving `command_policy.md` `Ask First` and `Forbidden` reason-code annotations match serialized `policy.commandReasons` metadata.
- Documented the contract as part of the existing `PolicyOutputContractTests` ownership boundary.

## Reason

Agents use the long command policy when the short context says to review approval or refusal detail. If the rendered reason-code annotations drift from JSON metadata, a machine consumer and a Markdown-only agent can interpret the same command differently.

## Expected Behavior

- Future command-policy rendering changes fail fast when full policy reason-code annotations no longer match metadata.
- The rendered command policy may keep its practical priority order without forcing JSON storage order to match Markdown order.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later reason-code or command ordering changes update JSON metadata and Markdown rendering together.
- Agents can trust either `scan_result.json` or `command_policy.md` for the same command-risk family.

## Failure Signals

- Full policy lines intentionally stop carrying reason codes.
- The command policy gains presentation-only command bullets that should not map to `policy.commandReasons`.

## Result

Unjudged.
