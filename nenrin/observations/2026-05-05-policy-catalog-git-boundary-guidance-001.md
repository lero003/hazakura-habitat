---
type: nenrin_observation
id: policy-catalog-git-boundary-guidance-001
date: 2026-05-05
related_changes:
  - policy-catalog-git-boundary-guidance
impact_judgment: effective
success_tags:
  - maintainability-boundary
  - no-output-change
failure_tags: []
---

# Observation: policy-catalog-git-boundary-guidance-001

## Task

Post-v0.4 self-use automation on the Hazakura Habitat repository.

## Observed Behavior

- The prior guidance changed this run's next action from broad `v0.5` evidence work into the narrow Git/GitHub catalog boundary slice.
- The existing partial edit had removed Git/GitHub command families from `PolicyReasonCatalog.swift` without adding the extension, and the follow-up build exposed the missing boundary as compile errors.
- Adding `PolicyReasonCatalog+Git.swift` restored the shared command-family ownership without changing the intended generated command policy.

## Success Signals Observed

- The guidance produced a small, reversible implementation slice with a clear file boundary.
- Build verification caught the incomplete extraction before test or commit.
- The slice kept reason-code definitions, rule ordering, fallback behavior, credential/auth families, DSLs, plugins, and external rule formats out of scope.

## Failure Signals Observed

- None observed.

## Impact Judgment

effective

## Next Action

- Keep future catalog splits tied to one cohesive command family and prove generated output stability with the existing policy tests.
