---
type: nenrin_observation
id: corepack-package-manager-activation-reason-001
date: 2026-05-04
related_changes:
  - corepack-package-manager-activation-reason
  - policy-command-family-wrapper
impact_judgment: effective
success_tags:
  - reason_code_specificity
  - command_family_centralized
failure_tags: []
---

# Observation: corepack-package-manager-activation-reason-001

## Task

Post-v0.3 self-use automation slice for v0.4 policy-engine hardening.

## Observed Behavior

- The self-scan kept the next command on SwiftPM validation and policy review before Git/GitHub mutation.
- Reading `command_policy.md` before planned Git mutation exposed that Corepack Ask First entries were still annotated with generic `user_approval_required`.
- The implementation response kept the command list stable but moved Corepack command ownership into `PolicyReasonCatalog` and added a specific `package_manager_activation` reason.

## Success Signals Observed

- `command_policy.md` now explains Corepack shim/version/project-metadata risk at each Corepack Ask First entry.
- `agent_context.md` overflow can name `package_manager_activation` as a hidden reason family without adding a new short-context bullet.
- The change followed the existing command-family wrapper pattern instead of adding a broader policy abstraction.

## Failure Signals Observed

- None observed in this slice.

## Impact Judgment

effective

## Next Action

- Keep observing whether new package-manager activation guards stay separate from dependency mutation and generic approval metadata.
