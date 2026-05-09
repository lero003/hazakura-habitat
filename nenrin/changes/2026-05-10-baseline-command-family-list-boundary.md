---
type: nenrin_change
id: baseline-command-family-list-boundary
date: 2026-05-10
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/PolicyReasonCatalog+BaselinePolicy.swift
  - Tests/HabitatCoreTests/PolicyReasonCatalogTests.swift
  - docs/current_status.md
  - docs/roadmap.md
review_after:
  tasks: 3
  days: 7
---

# Change: baseline-command-family-list-boundary

## Changed

- Added named baseline Ask First and Forbidden command-family lists in `PolicyReasonCatalog+BaselinePolicy.swift`.
- Made baseline policy assembly and ownership tests consume the same family lists.
- Preserved generated command order, counts, reason-code mapping, and Markdown policy output.

## Reason

The baseline policy catalog and tests were repeating the same family ordering by hand. That duplication made future policy-family edits more likely to update generated policy while leaving the ownership and coverage tests stale, or the reverse.

## Expected Behavior

- Future baseline command-family additions are made once in the catalog-owned family list.
- Tests continue checking duplicate entries, baseline ownership, and explicit exclusions without maintaining a second family-order list.
- Self-scan policy counts stay stable when this is only a maintainability slice.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later catalog-family edits update one baseline family list and tests stay aligned.
- Generated `command_policy.md` and `scan_result.json` remain stable after baseline maintenance.

## Failure Signals

- A future baseline family is added outside the named family lists.
- Tests stop detecting an omitted or duplicated static baseline command.

## Result

Unjudged.
