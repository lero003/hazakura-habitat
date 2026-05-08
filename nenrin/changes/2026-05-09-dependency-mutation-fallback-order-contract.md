---
type: nenrin_change
id: dependency-mutation-fallback-order-contract
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

# Change: dependency-mutation-fallback-order-contract

## Changed

- Added a `PolicyReasonCatalogTests` contract for dependency-mutation fallback ordering.
- Documented that broad mutation-shaped commands can still use `dependency_mutation`, while specific families keep their sharper reason codes.

## Reason

The generic mutation-word fallback is useful as a conservative catch-all, but it becomes misleading if it runs before specific command-family rules. This slice keeps the fallback behavior in place while preventing future edits from reclassifying SwiftPM resolution, version-manager edits, or workspace deletion under a generic dependency explanation.

## Expected Behavior

- Future reason-rule edits keep specific command-family rules ahead of the generic dependency-mutation fallback.
- Agents reading `command_policy.md` or `scan_result.json` see precise reason metadata when a more specific family exists.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later command-family additions preserve sharper reason codes without removing the conservative fallback.
- A future fallback-order regression fails in `PolicyReasonCatalogTests` before generated output drifts.

## Failure Signals

- The fallback contract becomes a proxy for broader rule-order design that should be modeled directly.
- New command families still rely on generic mutation-word matching when a specific reason family would change agent behavior.

## Result

Unjudged.
