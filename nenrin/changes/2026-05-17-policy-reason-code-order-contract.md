---
type: nenrin_change
id: policy-reason-code-order-contract
date: 2026-05-17
status: observing
impact: unknown
related_files:
  - docs/current_status.md
  - Tests/HabitatCoreTests/PolicyOutputContractTests.swift
review_after:
  tasks: 3
  days: 7
---

# Change: policy-reason-code-order-contract

## Changed

- Confirmed existing output-contract coverage already pins
  `policy.reasonCodes` to stable catalog order even when Ask First and
  Forbidden command lists arrive in a different order.
- Updated current status to describe that tested fixed-order legend as part of
  the narrow `policy.reasonCodes` stability boundary.

## Reason

`v0.9` hardening should classify small machine-readable boundaries before
`v1.0`. Agents and scripts can use `policy.reasonCodes` to explain command
decisions without parsing Markdown, but only if metadata diffs do not churn
because command lists happen to be reordered.

## Expected Behavior

- `policy.reasonCodes` remains additive to existing command arrays.
- The reason legend stays in catalog order, filtered to reason codes used by
  the generated policy.
- Future reason-code edits update the existing order contract and docs
  deliberately instead of changing metadata order by accident.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Machine consumers compare reason-code legends without command-order churn.
- `command_policy.md` and `scan_result.json` continue to agree on reason-code
  ordering.
- Future `v1.0` boundary decisions can treat reason-code ordering as a tested
  current behavior rather than implied status text.

## Failure Signals

- A future policy edit reorders `policy.reasonCodes` based on command-list
  order.
- The generated Markdown legend and JSON metadata diverge.
- New reason-code categories are added without a deliberate catalog-order
  decision.

## Result

Unjudged.
