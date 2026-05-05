---
type: nenrin_observation
id: policy-catalog-ephemeral-boundary-001
date: 2026-05-05
related_changes:
  - maintainability-split
  - policy-catalog-git-boundary-guidance
impact_judgment: effective
success_tags:
  - maintainability-boundary
  - no-output-change
failure_tags: []
---

# Observation: policy-catalog-ephemeral-boundary-001

## Task

Post-v0.4 self-use automation on the Hazakura Habitat repository.

## Observed Behavior

- The self-scan showed `ephemeral_package_execution` as an active generated reason family in the long command policy and short Ask First overflow.
- Prior Nenrin guidance kept the slice out of broad `v0.5` evidence normalization and pointed to a small catalog boundary instead.
- Extracting `npx`, `dlx`, `uvx`, and `pipx run` command families into `PolicyReasonCatalog+EphemeralPackageExecution.swift` preserved generated policy behavior while reducing `PolicyReasonCatalog.swift` growth.

## Success Signals Observed

- The change stayed within one cohesive command-decision family.
- The classification contract now checks every ephemeral package execution command instead of only a representative `npx` case.
- No scanner responsibility, reason-rule ordering, fallback behavior, credential/auth family, DSL, plugin, or external rule format changed.

## Failure Signals Observed

- None observed.

## Impact Judgment

effective

## Next Action

- Use the same file-boundary pattern only for the next clearly cohesive catalog family; avoid splitting by arbitrary line count alone.
