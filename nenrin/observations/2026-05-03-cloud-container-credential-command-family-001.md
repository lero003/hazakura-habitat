---
type: nenrin_observation
id: cloud-container-credential-command-family-001
date: 2026-05-03
related_changes:
  - cloud-container-credential-command-family
impact_judgment: effective
success_tags:
  - command_family_pattern_reused
  - cleanup_choice_improved
failure_tags: []
---

# Observation: cloud-container-credential-command-family-001

## Task

Post-v0.3 self-use automation slice for v0.4 policy-engine hardening.

## Observed Behavior

- The refreshed Habitat context kept the next command decision on SwiftPM verification and pointed Git/GitHub mutation review to `command_policy.md`.
- Reading the long policy showed the credential command-family hardening pattern now made adjacent package-manager credential/config duplication visible without changing the generated policy goal.
- The prior cloud/container credential-family change affected the cleanup choice by reinforcing that exact command families should move into `PolicyReasonCatalog` only when scanner generation and reason classification both own the same safety boundary.

## Success Signals Observed

- The next cleanup stayed narrow: package-manager credential/config forbids moved into one command family without adding broad cloud/container or package ecosystem expansion.
- Tests passed with generated-output behavior preserved.
- The policy review path still refuses cloud/container credential commands with `secret_or_credential_access`.

## Failure Signals Observed

- None observed in this slice.

## Impact Judgment

effective

## Next Action

- Keep the command-family pattern narrow; do not merge unrelated dependency mutation, publication, or host-private commands into credential families.
