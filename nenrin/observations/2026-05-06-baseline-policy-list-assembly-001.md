---
type: nenrin_observation
id: baseline-policy-list-assembly-001
date: 2026-05-06
related_changes:
  - baseline-policy-list-assembly
impact_judgment: effective
success_tags:
  - drift_reduced
  - generated_output_stable
failure_tags: []
---

# Observation: baseline-policy-list-assembly-001

## Task

Hourly Habitat self-use loop after catalog-family and test-suite ownership splits.

## Observed Behavior

- Self-scan still preferred `swift test` and `swift build` with no warnings.
- Scanner still assembled the full baseline Ask First and Forbidden command lists inline even though the command families and reason classification now lived in `PolicyReasonCatalog`.
- Moving only static baseline assembly into the catalog reduced scanner/catalog drift without changing the command decision.

## Success Signals Observed

- `swift test` passed with 211 tests.
- A refreshed self-scan kept the same short-context command decision and command counts.
- `PolicyReasonCatalogTests` now checks the static baseline list ownership directly.

## Failure Signals Observed

- None observed in this slice.

## Impact Judgment

effective

## Next Action

- Split scanner/package-manager fixture ownership only when a nearby behavior change needs it.
