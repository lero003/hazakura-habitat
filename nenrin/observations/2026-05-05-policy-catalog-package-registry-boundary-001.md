---
type: nenrin_observation
id: policy-catalog-package-registry-boundary-001
date: 2026-05-05
related_changes:
  - package-registry-reason-code
  - maintainability-split
impact_judgment: effective
success_tags:
  - maintainability-boundary
  - no-output-change
failure_tags: []
---

# Observation: policy-catalog-package-registry-boundary-001

## Task

Post-v0.4 self-use automation on the Hazakura Habitat repository.

## Observed Behavior

- The self-scan kept `package_registry_mutation` active in generated policy and short Ask First overflow while the current task still needed Git/GitHub mutation review before publication.
- Prior package-registry reason-code work already made publish, owner, dist-tag, yank, and trunk commands command-changing by separating external package-state risk from local dependency mutation.
- Extracting the package-registry mutation family into `PolicyReasonCatalog+PackageRegistry.swift` preserved generated output while reducing future drift between scanner command generation and reason classification.

## Success Signals Observed

- The change stayed inside one cohesive command-decision family.
- The classification contract now checks every package-registry mutation command from the centralized catalog.
- No scanner responsibility, reason-rule ordering, fallback behavior, credential/auth family, DSL, plugin, or external rule format changed.

## Failure Signals Observed

- None observed.

## Impact Judgment

effective

## Next Action

- Stop catalog extraction unless the next family boundary is equally cohesive or adjacent behavior work needs it.
