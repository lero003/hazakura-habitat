---
type: nenrin_change
id: review-first-ask-first-prefix-contract
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

# Change: review-first-ask-first-prefix-contract

## Changed

- Added a `PolicyOutputContractTests` contract proving `command_policy.md` `Review First` entries remain the reasoned prefix of the rendered `Ask First` section.
- Documented the contract as part of the policy navigation output boundary.

## Reason

Agents use `Review First` as the short approval checklist before scanning the full policy. It should stay a concise explanation of the highest-priority Ask First entries, not drift into a separate ordering model.

## Expected Behavior

- Future policy-priority edits keep `Review First` and the full `Ask First` list aligned.
- Generated-output changes that intentionally separate the two reading paths require an explicit test update.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later `command_policy.md` edits preserve the Review First to Ask First prefix relationship.
- Agents can trust the first approval checklist as the entry point into the full policy list.

## Failure Signals

- The prefix contract blocks a clearer policy navigation model.
- Agents still need to rescan the full Ask First section after reading Review First.

## Result

Unjudged.
