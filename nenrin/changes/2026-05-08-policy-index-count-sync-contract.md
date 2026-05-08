---
type: nenrin_change
id: policy-index-count-sync-contract
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

# Change: policy-index-count-sync-contract

## Changed

- Added an output-contract test proving `command_policy.md` `Policy Index` counts match generated policy metadata and rendered section contents.
- Documented the contract as part of the existing `PolicyOutputContractTests` ownership boundary.

## Reason

Agents use the compact policy index to decide whether the long policy needs deeper inspection. If its counts drift from generated metadata or rendered sections, an agent may underestimate risky approval or refusal surface area before choosing the next command.

## Expected Behavior

- Future command-policy rendering changes fail fast when the index count no longer matches metadata or section contents.
- Output-contract hardening remains local to generated policy tests without changing representative examples.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later policy section additions or removals update the index, metadata, and tests together.
- Agents can continue using the index as a quick size and navigation summary.

## Failure Signals

- The Policy Index intentionally becomes approximate rather than count-bearing.
- A future rendered section gains presentation-only bullets that should not count as policy entries.

## Result

Unjudged.
