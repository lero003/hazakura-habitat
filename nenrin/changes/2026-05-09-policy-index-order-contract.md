---
type: nenrin_change
id: policy-index-order-contract
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

# Change: policy-index-order-contract

## Changed

- Added a `PolicyOutputContractTests` contract that keeps `command_policy.md` `Policy Index` ordering aligned with the rendered policy section order.
- Documented the contract as part of the policy navigation output boundary.

## Reason

Agents use `Policy Index` as the short navigation layer before scanning long approval and forbidden command lists. Count sync alone does not catch a reordered index that sends agents through policy detail in a different sequence than the generated Markdown presents.

## Expected Behavior

- Future policy navigation edits keep conditional sections, short review guidance, and long command lists in a predictable order.
- Generated-output changes that reorder policy sections become an explicit test update instead of accidental drift.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later `command_policy.md` edits preserve the index/body order relationship without extra explanation.
- Agents can continue using the index as a compact reading guide before risky commands.

## Failure Signals

- The contract becomes too rigid for a clearer policy reading sequence.
- The index remains ordered but agents still need to scan the full policy to find the right approval point.

## Result

Unjudged.
