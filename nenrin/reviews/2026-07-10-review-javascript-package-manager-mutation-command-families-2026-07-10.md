---
type: nenrin_review
id: review-javascript-package-manager-mutation-command-families-2026-07-10
date: 2026-07-10
related_change: javascript-package-manager-mutation-command-families
final_judgment: keep
---

# Review: javascript-package-manager-mutation-command-families

## Summary

Keep. The JavaScript package-manager mutation family still earns its place as a
small catalog-owned command boundary for npm, pnpm, yarn, and bun dependency
mutation commands.

## Evidence

- `PolicyReasonCatalog+JavaScriptPackageManager.swift` still owns the npm,
  pnpm, yarn, and bun mutation command arrays in one local boundary, including
  `yarn up`.
- `PolicyReasonCatalog+ReasonRules.swift` routes those commands through the
  `dependency_mutation` reason rule instead of relying only on the broad
  fallback word match.
- `JavaScriptCommandPolicyTests.scanGuardsJavaScriptDependencyMutationCommands`
  verifies those package-manager mutation commands remain Ask First and render
  into `command_policy.md`.
- `PolicyReasonCatalogTests.catalogFamilyExtractionsPreserveClassification`
  verifies every centralized JavaScript package-manager mutation command keeps
  the `dependency_mutation` reason code after family extraction.
- A fresh temporary Habitat scan on 2026-07-10 kept SwiftPM as the local
  validation path and still rendered npm, pnpm, yarn, and bun install/update
  and removal commands as `dependency_mutation` in `command_policy.md`.
- The related observation showed behavior evidence: the cleanup narrowed one
  scanner/catalog duplication and corrected `yarn up` reason metadata without
  broadening JavaScript ecosystem policy.

## Decision

- keep

## Cleanup

- No cleanup now. Future JavaScript package-manager edits should keep this
  family narrow: dependency mutation commands belong here, while package
  registry publication, package-manager activation, ephemeral execution, and
  metadata/version mismatch behavior should stay in their separate policy
  families.
