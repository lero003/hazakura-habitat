---
type: nenrin_change
id: reason-rule-catalog-boundary
date: 2026-05-10
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/PolicyReasonCatalog+ReasonRules.swift
  - Sources/HabitatCore/PolicyReasonCatalog.swift
  - docs/current_status.md
  - docs/roadmap.md
review_after:
  tasks: 3
  days: 7
---

# Change: reason-rule-catalog-boundary

## Changed

- Split Ask First and Forbidden reason-rule tables into `PolicyReasonCatalog+ReasonRules.swift`.
- Kept `PolicyReasonCatalog.swift` focused on finding generation and fallback classification helpers.
- Preserved command order, reason-code mapping, and generated policy output.

## Reason

Reason-rule ordering is a command-decision boundary: moving a specific family behind a fallback can make generated guidance less precise. Keeping the rule tables in their own file makes future policy work review the ordering directly instead of mixing it with finding assembly.

## Expected Behavior

- `command_policy.md`, `scan_result.json`, `commandReasons`, and `reviewFirstCommandReasons` stay unchanged.
- Future catalog-family edits check the rule table boundary before adding or moving fallback logic.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later policy-family changes preserve specific reason codes ahead of generic fallbacks.
- Self-scan keeps the same Ask First / Forbidden counts after rule-table maintenance.

## Failure Signals

- A future command family is added only to a baseline list and falls through to a generic reason.
- Rule-order changes become harder to review because they move outside the dedicated boundary.

## Result

Unjudged.
