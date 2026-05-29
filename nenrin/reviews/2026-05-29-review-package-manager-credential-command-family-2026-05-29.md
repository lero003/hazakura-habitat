---
type: nenrin_review
id: review-package-manager-credential-command-family-2026-05-29
date: 2026-05-29
related_change: package-manager-credential-command-family
final_judgment: keep
---

# Review: package-manager-credential-command-family

## Summary

Keep. The package-manager credential/config command family has earned its
place as a narrow credential-safety boundary.

## Evidence

- `PolicyReasonCatalog+PackageManagerCredential.swift` still owns the package
  manager credential/session and config command family in one local boundary.
- `PolicyReasonCatalogTests` checks every command in
  `packageManagerCredentialAndConfigCommands` keeps
  `secret_or_credential_access` instead of falling back to a generic reason.
- `CredentialPolicyTests` still verifies representative npm, pnpm, Yarn,
  RubyGems, Cargo, CocoaPods, and config commands are forbidden and rendered in
  `command_policy.md`.
- Current generated `habitat-report/command_policy.md` still labels package
  manager config, token, login/session, and Bundler/Cargo/CocoaPods credential
  commands as `secret_or_credential_access`.
- Adjacent credential-family work later split CLI auth and cloud/container
  credential families separately, so this record did not grow into broad
  dependency mutation, package publication, or generic credential policy.

## Decision

- keep

## Cleanup

- No cleanup now. Future additions should keep package-manager credential,
  session, and config commands in this family only when they share the same
  credential-safety behavior.
