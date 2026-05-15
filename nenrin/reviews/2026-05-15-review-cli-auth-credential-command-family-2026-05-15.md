---
type: nenrin_review
id: review-cli-auth-credential-command-family-2026-05-15
date: 2026-05-15
related_change: cli-auth-credential-command-family
final_judgment: keep
---

# Review: cli-auth-credential-command-family

## Summary

Keep the CLI auth and credential-store command family as earned guidance.

## Evidence

- `cli-auth-credential-command-family-001` changed the cleanup choice: adjacent credential policy work reused the one-family pattern instead of adding a broader policy abstraction.
- `policy-catalog-cli-auth-boundary-001` later extracted the CLI auth/session and credential-store family into `PolicyReasonCatalog+CliAuth.swift` while preserving generated output.
- Current code, tests, and docs still pin `gh auth`, Git credential-helper, and macOS `security` commands to `secret_or_credential_access`.
- The evidence is behavior evidence: it narrowed later context gathering and implementation boundaries, not merely record creation.

## Decision

- keep

## Cleanup

- No cleanup needed now. Future credential-family extraction should remain limited to cohesive command-decision families with tests that preserve generated output.
