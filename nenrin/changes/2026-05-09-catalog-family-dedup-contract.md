---
type: nenrin_change
id: catalog-family-dedup-contract
date: 2026-05-09
status: observing
impact: unknown
related_files:
  - Tests/HabitatCoreTests/PolicyReasonCatalogTests.swift
  - CHANGELOG.md
  - docs/current_status.md
  - docs/roadmap.md
  - docs/self_use.md
review_after:
  tasks: 3
  days: 7
---

# Change: catalog-family-dedup-contract

## Changed

- Added a PolicyReasonCatalogTests contract proving catalog command-family arrays do not contain duplicate commands before baseline policy, selected-workflow review routing, or generated reason-code metadata consume them.

## Reason

Policy catalog maintenance now depends on many small command-family files. A duplicate inside a family can look harmless locally but inflate generated policy, skew counts, or make Review First routing noisier once the family is assembled into output.

## Expected Behavior

- Future command-family edits fail tests when they accidentally add duplicate commands.
- Generated policy size and command counts stay tied to intentional catalog additions rather than repeated entries.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- A later catalog edit catches duplicate policy entries before docs, examples, or output contracts drift.
- Agents keep seeing concise command policy rather than repeated variants from the same catalog family.

## Failure Signals

- The contract becomes too broad to maintain when a family intentionally aliases commands.
- Generated output gains duplicates despite the family-level test.

## Result

Unjudged.
