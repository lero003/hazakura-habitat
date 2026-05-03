---
type: nenrin_change
id: policy-reason-rule-tables
date: 2026-05-03
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/PolicyReasonCatalog.swift
  - docs/current_status.md
review_after:
  tasks: 3
  days: 7
---

# Change: policy-reason-rule-tables

## Changed

- Replaced long ordered condition chains in `PolicyReasonCatalog` with explicit ordered reason-rule tables.
- Kept the same reason-code catalog, fallback reasons, and generated output behavior.

## Reason

The v0.3 self-use scan produced a long advisory command policy where reason codes affected the next command by explaining Git, dependency, and host-safety guards. For v0.4, those classifications need to stay maintainable as more policy findings are added; rule-table structure makes matching order and fallback behavior easier to review.

## Expected Behavior

- Agents keep seeing the same generated reason codes and policy wording.
- Future policy hardening changes can add or move one matching criterion without editing renderer logic or scanning a long condition chain.
- Reviewers can audit command-to-reason classification order directly from the catalog tables.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- A later reason-code change touches the relevant table entry without changing unrelated renderer code.
- Generated output snapshots remain stable when the change is purely structural.
- Review feedback can discuss keep, narrow, merge, or move decisions at the policy-rule level.

## Failure Signals

- Rule tables grow into a hidden DSL instead of simple classification criteria.
- Generated output changes unexpectedly after structural edits.
- New reason-code work still duplicates matching rules outside the catalog.

## Result

Unjudged.
