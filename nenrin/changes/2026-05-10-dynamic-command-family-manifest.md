---
type: nenrin_change
id: dynamic-command-family-manifest
date: 2026-05-10
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/PolicyReasonCatalog+CommandFamilies.swift
  - Sources/HabitatCore/PolicyReasonCatalog.swift
  - Tests/HabitatCoreTests/BaselineCommandCatalogTests.swift
  - docs/current_status.md
  - docs/roadmap.md
  - docs/self_use.md
review_after:
  tasks: 3
  days: 7
---

# Change: dynamic-command-family-manifest

## Changed

- Split non-baseline Ask First catalog families into `PolicyReasonCatalog.dynamicAskFirstCommandFamilies`.
- Added a `BaselineCommandCatalogTests` contract that keeps dynamic catalog families limited to SwiftPM dependency resolution and secret-bearing broad search.
- Synced status, roadmap, and self-use docs with the narrower dynamic-family boundary.
- Renamed the manifest source case and factory from generic `dynamic` to `dynamicAskFirst`, preserving generated output while making the policy side explicit.

## Reason

The catalog manifest should not quietly become a broad evidence or policy aggregation layer. Today the only non-baseline families are selected SwiftPM workflow commands and secret-bearing broad-search shape, both of which directly change the next command.

## Expected Behavior

- Generated policy output, command order, reason codes, Markdown, and JSON stay unchanged.
- Future non-baseline Ask First catalog families require an explicit test update that explains the command-decision boundary.
- A future dynamic Forbidden family should require a separate source case instead of reusing the Ask First path.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later dynamic catalog additions are deliberate and tied to a command-changing self-use or fixture case.
- Baseline family work stays separate from provisional evidence-alignment expansion.

## Failure Signals

- The exact dynamic-family list becomes churn-prone without improving generated output or command decisions.

## Result

Unjudged.
