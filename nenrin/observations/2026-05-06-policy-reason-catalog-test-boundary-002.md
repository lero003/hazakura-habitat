---
type: nenrin_observation
id: policy-reason-catalog-test-boundary-002
date: 2026-05-06
related_changes:
  - policy-reason-catalog-test-boundary
impact_judgment: effective
success_tags:
  - maintainability
  - test-ownership
failure_tags: []
---

# Observation: policy-reason-catalog-test-boundary-002

## Task

Hourly Habitat self-use loop after the dedicated catalog test suite already existed.

## Observed Behavior

- A remaining package-manager review routing contract was still in `HabitatCoreTests.swift`.
- The dedicated catalog suite made the correct home for that contract obvious, so the slice moved coverage without changing generated output or reason-code behavior.

## Success Signals Observed

- Test ownership changed the next cleanup decision: catalog routing assertions now live with catalog-family classification contracts.
- `HabitatCoreTests.swift` no longer owns package-manager review routing internals.

## Failure Signals Observed

- None observed in this slice.

## Impact Judgment

effective

## Next Action

- Stop adding catalog internals to broad scanner or fixture suites.
