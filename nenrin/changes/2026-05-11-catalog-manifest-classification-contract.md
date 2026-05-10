---
type: nenrin_change
id: catalog-manifest-classification-contract
date: 2026-05-11
status: observing
impact: unknown
related_files:
  - Tests/HabitatCoreTests/BaselineCommandCatalogTests.swift
  - Tests/HabitatCoreTests/BehaviorEvaluationTests.swift
  - examples/behavior-evaluation/swiftpm-self-use-014.json
  - docs/evaluation.md
  - examples/README.md
review_after:
  tasks: 3
  days: 7
---

# Change: catalog-manifest-classification-contract

## Changed

- Added a `BaselineCommandCatalogTests` contract that runs a small generated policy and checks catalog manifest sources against generated `PolicyFinding` sides.
- Recorded `swiftpm-self-use-014` as sanitized behavior evidence for choosing a narrow catalog-drift contract instead of broad evidence-normalization work.
- Updated evaluation and example indexes for the new fixture.

## Reason

The catalog manifest now carries source labels that future maintainers will use before changing policy output. Those labels should be tested against generated command-reason sides, not only against static ownership lists, so a future source or rendering drift fails before an agent sees misleading policy metadata.

## Expected Behavior

- Future catalog-family edits check whether dynamic Ask First, baseline Ask First, and baseline Forbidden families still land on the generated PolicyFinding side their source declares.
- Self-use evidence keeps this as a maintainability guard, not a reason to start a broad normalized-evidence layer.
- Generated Markdown and JSON policy output stay stable unless a later command-decision gap justifies changing them.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- A later catalog edit is caught or clarified by the generated PolicyFinding-side contract.
- Agents continue using SwiftPM verification and bounded read-only inspection before catalog maintenance slices.

## Failure Signals

- The new contract becomes redundant with static manifest checks and never affects review decisions.
- Catalog source metadata changes without corresponding generated policy-side review.

## Result

Unjudged.
