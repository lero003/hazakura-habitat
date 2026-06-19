---
type: nenrin_review
id: review-corepack-package-manager-activation-reason-2026-06-19
date: 2026-06-19
related_change: corepack-package-manager-activation-reason
final_judgment: keep
---

# Review: corepack-package-manager-activation-reason

## Summary

Keep. The Corepack activation reason still earns its place as a narrow
package-manager shim, version, and project-metadata boundary rather than a
generic approval label or dependency-mutation label.

## Evidence

- `PolicyReasonCatalog+PackageManagerActivation.swift` owns the Corepack
  activation command family in one local boundary.
- `PolicyReasonCatalogTests` keeps Corepack activation ahead of the generic
  dependency-mutation fallback and checks every centralized Corepack command
  retains `package_manager_activation`.
- `JavaScriptCommandPolicyTests` checks `corepack enable`, `corepack install`,
  and `corepack use` classify as `package_manager_activation`, and that
  `command_policy.md` renders the same reason code for every Corepack
  activation command.
- `PolicyOutputContractTests` keeps `package_manager_activation` in the stable
  reason legend order.
- `docs/current_status.md` and `docs/agent_contract.md` still describe the
  same command boundary: ask first because these commands can change shims,
  fetch package-manager versions, or mutate project package-manager metadata.
- The related observations already showed behavior evidence: the prior record
  changed the cleanup choice toward a no-output-change catalog boundary instead
  of broad package-manager coverage.

## Decision

- keep

## Cleanup

- No cleanup now. Future Corepack additions should stay in this family only
  when they affect package-manager activation; dependency edits, registry
  mutation, and credential/session behavior should remain in their separate
  reason families.
