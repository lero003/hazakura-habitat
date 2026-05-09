---
type: nenrin_change
id: baseline-static-guard-boundary
date: 2026-05-09
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/PolicyReasonCatalog+BaselineStaticGuards.swift
  - Sources/HabitatCore/PolicyReasonCatalog+BaselinePolicy.swift
  - Sources/HabitatCore/PolicyReasonCatalog.swift
  - Tests/HabitatCoreTests/PolicyReasonCatalogTests.swift
  - docs/current_status.md
  - docs/roadmap.md
review_after:
  tasks: 3
  days: 7
---

# Change: baseline-static-guard-boundary

## Changed

- Split baseline static guards for lockfile mutation, core Forbidden commands, and secret-value Forbidden commands into a named catalog boundary.
- Routed lockfile and baseline secret-value reason classification through the named guard helpers.
- Updated catalog ownership tests to consume the named guard families instead of repeating inline strings.

## Reason

Baseline policy assembly had mostly moved into catalog-owned families, but a few static guards still lived as literals inside assembly and tests. Naming them reduces drift risk when future command-policy edits touch baseline output or reason-code routing.

## Expected Behavior

- Generated command order, reason codes, Markdown, and `scan_result.json` stay unchanged.
- Future baseline static guard edits start in `PolicyReasonCatalog+BaselineStaticGuards.swift` and are covered by existing catalog ownership tests.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later baseline policy edits reuse the named guard families instead of adding inline literals.
- Self-scan keeps the same short-context and command-policy counts.

## Failure Signals

- New baseline static guards are added directly to assembly or tests.
- Maintainability-only catalog work changes generated policy output unintentionally.

## Result

Unjudged.
