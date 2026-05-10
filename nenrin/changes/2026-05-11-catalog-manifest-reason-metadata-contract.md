---
type: nenrin_change
id: catalog-manifest-reason-metadata-contract
date: 2026-05-11
status: observing
impact: unknown
related_files:
  - Tests/HabitatCoreTests/BaselineCommandCatalogTests.swift
  - Tests/HabitatCoreTests/BehaviorEvaluationTests.swift
  - examples/behavior-evaluation/swiftpm-self-use-015.json
  - docs/evaluation.md
  - docs/current_status.md
  - docs/self_use.md
  - docs/roadmap.md
  - examples/README.md
review_after:
  tasks: 3
  days: 7
---

# Change: catalog-manifest-reason-metadata-contract

## Changed

- Added a `BaselineCommandCatalogTests` contract that compares each catalog manifest command with generated `PolicyCommandReason` classification and reason metadata.
- Recorded `swiftpm-self-use-015` as sanitized behavior evidence for choosing a no-output catalog metadata contract instead of broad policy or evidence changes.
- Updated evaluation, example, status, roadmap, and self-use notes for the new contract.

## Reason

The previous manifest-side contract proved commands landed on the generated Ask First or Forbidden side. A command could still land on the right side with stale or mismatched reason metadata, which would weaken the AI-facing command explanation without changing the command list. This check keeps source ownership and generated reason metadata tied together before more catalog growth.

## Expected Behavior

- Future catalog-family edits fail if generated `PolicyCommandReason` metadata drifts from the manifest source and catalog reason mapping.
- Agents can keep trusting reason-coded generated policy entries without reading implementation-specific catalog files.
- Generated Markdown and JSON output stay stable unless a later command-decision gap justifies changing them.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- A later catalog edit is caught or clarified by the generated reason-metadata contract.
- Catalog maintenance continues as small no-output slices when behavior does not need to change.

## Failure Signals

- The new contract duplicates existing command-reason tests without improving review clarity.
- Generated reason metadata changes without a fixture or output-contract review.

## Result

Unjudged.
