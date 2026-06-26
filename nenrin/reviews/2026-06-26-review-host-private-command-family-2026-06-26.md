---
type: nenrin_review
id: review-host-private-command-family-2026-06-26
date: 2026-06-26
related_change: host-private-command-family
final_judgment: keep
---

# Review: host-private-command-family

## Summary

Keep. The host-private command family still earns its place as a narrow local
privacy boundary for environment dumps, clipboard reads, shell history, browser
profiles, and local mail rather than a generic unsafe-command label.

## Evidence

- `PolicyReasonCatalog+HostPrivate.swift` owns the host-private command family
  in one local boundary.
- `PolicyReasonCatalog+ReasonRules.swift` routes host-private commands before
  the credential and generic unsafe-command fallbacks, while
  `PolicyReasonCatalog+BaselinePolicy.swift` keeps the family in the baseline
  Forbidden manifest.
- `HostPrivateDataPolicyTests` verifies generated scanner output, short
  context wording, command policy entries, and `host_private_data` reason
  annotations for environment, clipboard, shell-history, browser, and mail
  commands.
- `PolicyReasonCatalogTests` verifies every centralized host-private command
  keeps `host_private_data` and that specific sentinel commands such as
  `pbpaste` and `cat ~/.zsh_history` do not fall back to generic metadata.
- `docs/current_status.md` still describes the same boundary and separates it
  from credential, SSH private-key, secret-file, package-manager, and cloud
  credential policy families.
- The related observations showed behavior evidence: generated context kept
  agents on project-local docs, `rg`, and SwiftPM verification, and the later
  catalog-boundary pass chose a no-output-change local family boundary instead
  of broader host privacy coverage.

## Decision

- keep

## Cleanup

- No cleanup now. Future host-private additions should remain limited to local
  host data access. Credential/session, SSH private-key, secret-file, package
  manager, and cloud/container credential behavior should stay in their
  separate families.
