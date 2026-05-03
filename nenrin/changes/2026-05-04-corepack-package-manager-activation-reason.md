---
type: nenrin_change
id: corepack-package-manager-activation-reason
date: 2026-05-04
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/PolicyReasonCatalog.swift
  - Sources/HabitatCore/Scanner.swift
  - Tests/HabitatCoreTests/HabitatCoreTests.swift
  - docs/agent_contract.md
  - docs/current_status.md
review_after:
  tasks: 3
  days: 7
---

# Change: corepack-package-manager-activation-reason

## Changed

- Added a `package_manager_activation` reason family for Corepack commands.
- Centralized `corepack enable`, `corepack disable`, `corepack prepare`, `corepack install`, `corepack use`, and `corepack up` in `PolicyReasonCatalog`.
- Made scanner Ask First command generation consume the same Corepack command family used by reason classification.

## Reason

The v0.3 self-use policy review showed Corepack commands were already Ask First, but long-policy entries still used generic `user_approval_required` metadata. That made `corepack enable`, `corepack prepare`, and `corepack use` less explainable than adjacent package-manager policy even though they can change shims, fetch package-manager versions, or mutate project package-manager metadata.

## Expected Behavior

- Generated Ask First command lists and ordering remain unchanged.
- Corepack activation commands are annotated as `package_manager_activation`.
- Agents reviewing `command_policy.md` can distinguish package-manager activation risk from generic approval gates.
- Future Corepack command changes update one command-family owner instead of duplicating scanner and classifier literals.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Self-use policy review sees `package_manager_activation` in the reason legend and Corepack Ask First entries.
- Corepack command additions do not reintroduce scanner-local literals without catalog classification.
- Agents continue to ask before Corepack activation without treating it as dependency install/remove behavior.

## Failure Signals

- Corepack commands fall back to `user_approval_required`.
- The new reason family is applied to unrelated package-manager installs, registry mutations, or version mismatch guards.
- `agent_context.md` overflow becomes noisier without improving policy review.

## Result

Unjudged.
