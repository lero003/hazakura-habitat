---
type: nenrin_change
id: fallback-reason-legend-contract
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

# Change: fallback-reason-legend-contract

## Changed

- Added a `PolicyOutputContractTests` contract for generic Ask First and Forbidden fallback reason codes.
- Documented that fallback reason codes remain part of `policy.reasonCodes` when unmatched command families use them.

## Reason

Generated policy can contain dynamic or future command families that do not match a specific catalog rule yet. Those commands still need compact explanation in `scan_result.json` and `command_policy.md`; otherwise an agent sees a reason code on the command line without a matching legend entry.

## Expected Behavior

- Future unmatched Ask First commands keep the `user_approval_required` legend entry.
- Future unmatched Forbidden commands keep the `unsafe_or_sensitive_command` legend entry.
- Agents can trust that every rendered fallback reason code remains explainable without parsing catalog internals.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later dynamic policy additions keep generic fallback explanations in metadata and Markdown.
- A missing fallback legend entry fails in `PolicyOutputContractTests` before generated output drifts.

## Failure Signals

- The contract encourages broad use of generic fallback instead of adding specific reason families where command risk is clear.
- New command families render fallback reason codes that are technically covered but too vague to guide the next command.

## Result

Unjudged.
