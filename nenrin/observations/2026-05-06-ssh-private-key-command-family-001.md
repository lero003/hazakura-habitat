---
type: nenrin_observation
id: ssh-private-key-command-family-001
date: 2026-05-06
related_changes:
  - ssh-private-key-command-family
impact_judgment: effective
success_tags:
  - drift_reduced
  - generated_output_stable
failure_tags: []
---

# Observation: ssh-private-key-command-family-001

## Task

Run the post-`v0.4.0` self-use maintainability loop after workspace mutation extraction.

## Observed Behavior

- Self-scan still preferred `swift test` and `swift build` with no warnings.
- The large inline SSH private-key Forbidden list in `Scanner.swift` was the next cohesive catalog boundary.
- Extracting it reduced scanner ownership while keeping the secret-safety command decision unchanged.

## Success Signals Observed

- `swift test` passed with 207 tests.
- Catalog classification coverage confirms every extracted SSH private-key command keeps `secret_or_credential_access`.
- Self-scan command counts remained stable after the no-output-change extraction.

## Failure Signals Observed

- None observed in this slice.

## Impact Judgment

effective

## Next Action

- Keep future secret-safety catalog work equally narrow; do not add broader evidence normalization without a measured command-decision need.
