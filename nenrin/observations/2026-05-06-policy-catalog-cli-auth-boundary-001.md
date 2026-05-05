---
type: nenrin_observation
id: policy-catalog-cli-auth-boundary-001
date: 2026-05-06
related_changes:
  - cli-auth-credential-command-family
  - maintainability-split
impact_judgment: effective
success_tags:
  - maintainability-boundary
  - no-output-change
  - credential-safety
failure_tags: []
---

# Observation: policy-catalog-cli-auth-boundary-001

## Task

Post-v0.4 self-use automation on the Hazakura Habitat repository.

## Observed Behavior

- The self-scan kept `secret_or_credential_access` active in generated policy while the current task needed command-policy review before Git/GitHub mutation.
- Prior CLI auth and credential-store work already made `gh auth`, Git credential-helper, and macOS `security` commands command-changing by classifying them as credential/session risk.
- Extracting the CLI auth-session and credential-store family into `PolicyReasonCatalog+CliAuth.swift` preserved generated output while reducing future drift between scanner command generation and reason classification.

## Success Signals Observed

- The change stayed inside one cohesive credential/session command family.
- The classification contract now checks every CLI auth and credential-store command from the centralized catalog.
- No scanner responsibility, reason-rule ordering, fallback behavior, package-manager credential family, cloud/container credential family, DSL, plugin, or external rule format changed.

## Failure Signals Observed

- None observed.

## Impact Judgment

effective

## Next Action

- Stop credential catalog extraction unless the next family boundary is equally cohesive or adjacent behavior work needs it.
