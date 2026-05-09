---
type: nenrin_change
id: reason-code-catalog-boundary
date: 2026-05-09
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/PolicyReasonCatalog+ReasonCodes.swift
  - Sources/HabitatCore/PolicyReasonCatalog.swift
  - docs/current_status.md
  - docs/roadmap.md
review_after:
  tasks: 3
  days: 7
---

# Change: reason-code-catalog-boundary

## Changed

- Split the reason-code enum, reason text, and legend ordering into `PolicyReasonCatalog+ReasonCodes.swift`.
- Kept `PolicyReasonCatalog.swift` focused on rule ordering, finding generation, and fallback classification helpers.
- Left generated policy output, command order, and tests unchanged.

## Reason

Reason-code definitions were stable product vocabulary, while rule ordering remains an implementation risk. Keeping them in a named boundary reduces drift risk when future policy work edits rule tables or command families.

## Expected Behavior

- Generated `command_policy.md`, `scan_result.json`, command reason metadata, and reason-legend ordering stay unchanged.
- Future reason-code text or ordering changes start in the dedicated reason-code boundary instead of the rule-routing file.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later policy-rule edits avoid incidental reason-code text or order changes.
- Self-scan keeps the same Ask First / Forbidden counts and reason-code legend order.

## Failure Signals

- A rule-order refactor changes reason text or legend ordering unintentionally.
- New reason codes are added outside the dedicated boundary.

## Result

Unjudged.
