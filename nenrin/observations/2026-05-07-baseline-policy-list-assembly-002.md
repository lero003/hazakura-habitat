---
type: nenrin_observation
id: baseline-policy-list-assembly-002
date: 2026-05-07
related_changes:
  - baseline-policy-list-assembly
impact_judgment: effective
success_tags:
  - drift_reduced
  - generated_output_stable
failure_tags: []
---

# Observation: baseline-policy-list-assembly-002

## Task

Hourly Habitat self-use loop after baseline policy-list ownership moved from `Scanner` into `PolicyReasonCatalog`.

## Observed Behavior

- Self-scan still preferred `swift test` and `swift build` with no warnings.
- The baseline Ask First and Forbidden lists were catalog-owned, but still lived in the reason-rule core file.
- Splitting them into `PolicyReasonCatalog+BaselinePolicy.swift` kept broad policy-list edits near the command-family files and left `PolicyReasonCatalog.swift` focused on reason codes and classification.

## Success Signals Observed

- `PolicyReasonCatalogTests.baselineCommandCatalogOwnsStaticPolicyLists` still checks the static list contract.
- Generated command counts, short-context guidance, and reason-code behavior are intended to stay unchanged.

## Failure Signals Observed

- None observed in this slice.

## Impact Judgment

effective

## Next Action

- Split scanner/package-manager fixture ownership only when a nearby behavior change needs it.
