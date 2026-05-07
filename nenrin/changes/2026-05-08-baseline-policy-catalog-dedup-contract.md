---
type: nenrin_change
id: baseline-policy-catalog-dedup-contract
date: 2026-05-08
status: observing
impact: unknown
related_files:
  - Tests/HabitatCoreTests/PolicyReasonCatalogTests.swift
  - CHANGELOG.md
  - docs/current_status.md
  - docs/roadmap.md
review_after:
  tasks: 3
  days: 7
---

# Change: baseline-policy-catalog-dedup-contract

## Changed

- Added a catalog contract that checks baseline Ask First and Forbidden policy lists for duplicate entries.
- Added a cross-classification check so the same baseline command cannot silently render as both Ask First and Forbidden.

## Reason

Baseline policy lists are now assembled from many command families. A future family extraction or catalog edit could accidentally duplicate rendered policy entries, inflating `command_policy.md`, command counts, and reason metadata without changing any individual classifier.

## Expected Behavior

- Future baseline catalog edits fail fast if they introduce duplicate rendered policy entries.
- Agents keep seeing concise policy output instead of repeated commands caused by catalog assembly drift.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- A later baseline catalog edit catches duplicate command entries before generated Markdown changes.
- Policy output remains concise while new command families are added.

## Failure Signals

- The contract blocks an intentional classification overlap that needs a more explicit model.
- Generated policy output grows through dynamic command insertion that this baseline-only check does not cover.

## Result

Unjudged.
