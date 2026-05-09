---
type: nenrin_change
id: command-policy-ask-first-priority-order
date: 2026-05-09
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

# Change: command-policy-ask-first-priority-order

## Changed

- Added a `PolicyOutputContractTests` contract that keeps rendered `command_policy.md` `Ask First` priority order explicit for secret-bearing search, missing-tool, selected package-manager, lockfile, and Git risks.
- Documented the extra contract as part of the policy output navigation boundary.

## Reason

The previous line-sync contract proved the same command/reason-code pairs existed in Markdown and JSON, but the rendered long policy intentionally uses practical reading priority rather than raw catalog order. Agents use `command_policy.md` when reviewing risky commands, so that priority should be explicit and tested instead of accidental.

## Expected Behavior

- Future command-policy rendering edits keep command-changing risks near the top of the long Ask First section.
- Machine consumers can still use JSON metadata while Markdown-only agents get a stable review order.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later `command_policy.md` edits preserve the practical Ask First priority without extra explanation.
- Agents can navigate long approval sections without first scanning broad baseline policy families.

## Failure Signals

- The policy intentionally gains presentation-only sorting that should not affect JSON metadata.
- The contract blocks a clearer command grouping that should become an explicit generated-output change.

## Result

Unjudged.
