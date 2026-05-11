---
type: nenrin_change
id: baseline-static-guard-source-split
date: 2026-05-11
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/PolicyReasonCatalog+BaselineLockfile.swift
  - Sources/HabitatCore/PolicyReasonCatalog+BaselineHostBoundary.swift
  - Sources/HabitatCore/PolicyReasonCatalog+BaselineSecretValue.swift
  - Sources/HabitatCore/PolicyReasonCatalog+BaselinePolicy.swift
  - docs/current_status.md
  - docs/roadmap.md
  - docs/self_use.md
review_after:
  tasks: 3
  days: 7
---

# Change: baseline-static-guard-source-split

## Changed

- Split the previous baseline static-guard file into separate lockfile mutation, host-boundary, and secret-value guard boundaries.
- Preserved existing public catalog property names and reason-routing helpers, so generated policy order and metadata should stay unchanged.
- Updated status, roadmap, and self-use notes to name the smaller source boundaries.

## Reason

The baseline static guard file mixed one Ask First command-decision shape with two Forbidden guard shapes. Keeping those families separate reduces drift risk when future work touches lockfile policy, host-boundary safety, or secret-value guidance independently.

## Expected Behavior

- Future edits start in the smallest matching static guard file instead of reopening a mixed catch-all file.
- Generated `agent_context.md`, `command_policy.md`, `scan_result.json`, command counts, and reason codes stay stable.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later baseline guard edits reuse the split source files without changing unrelated guard families.
- Catalog manifest and output-contract tests continue to prove no generated-output drift.

## Failure Signals

- The split makes tiny baseline guard edits harder to find.
- Future changes recreate a broad mixed static-guard file.

## Result

Unjudged.
