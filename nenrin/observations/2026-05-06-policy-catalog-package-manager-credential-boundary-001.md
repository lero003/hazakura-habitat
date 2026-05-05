---
type: nenrin_observation
id: policy-catalog-package-manager-credential-boundary-001
date: 2026-05-06
related_changes:
  - package-manager-credential-command-family
  - maintainability-split
impact_judgment: effective
success_tags:
  - maintainability-boundary
  - no-output-change
  - credential-safety
failure_tags: []
---

# Observation: policy-catalog-package-manager-credential-boundary-001

## Task

Post-v0.4 self-use automation on the Hazakura Habitat repository.

## Observed Behavior

- The self-scan kept `secret_or_credential_access` active in generated policy while `command_policy.md` still carried many package-manager credential/session and config forbids.
- Prior package-manager credential/config work already centralized pip/npm/pnpm/yarn/Bundler/Cargo/CocoaPods credential commands, but the family still lived inside the main `PolicyReasonCatalog.swift` file.
- Extracting the package-manager credential/config family into `PolicyReasonCatalog+PackageManagerCredential.swift` preserved generated output while reducing future drift between scanner command generation and reason classification.

## Success Signals Observed

- The change stayed inside one cohesive credential/config command family.
- The classification contract now checks every package-manager credential/config command from the centralized catalog.
- No scanner responsibility, reason-rule ordering, fallback behavior, CLI auth family, cloud/container credential family, DSL, plugin, or external rule format changed.

## Failure Signals Observed

- None observed.

## Impact Judgment

effective

## Next Action

- Keep the remaining credential catalog boundary work limited to equally cohesive families, if policy review exposes one.
