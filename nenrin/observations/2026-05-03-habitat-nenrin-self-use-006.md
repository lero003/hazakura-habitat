---
type: nenrin_observation
id: habitat-nenrin-self-use-006
date: 2026-05-03
related_changes:
  - habitat-nenrin-self-use
  - nenrin-active-index-links
impact_judgment: effective
success_tags:
  - active_index_link_used
  - next_command_changed
  - policy_structure_hardened
failure_tags: []
---

# Observation: habitat-nenrin-self-use-006

## Task

Post-v0.3 self-use automation slice for v0.4 policy-engine hardening.

## Observed Behavior

- Habitat self-scan kept substantial work on SwiftPM verification and generated policy review before code edits or Git/GitHub mutation.
- `nenrin/index.md` exposed the observing records directly, so the agent opened the active change files from the index instead of searching the repository to locate current Nenrin context.
- The policy review showed reason-code consistency is central to the generated `command_policy.md` and `scan_result.json` contract; the implementation response centralized reason-code text in `PolicyReasonCatalog` without changing generated output.

## Success Signals Observed

- Active Nenrin links changed the context-gathering command path from discovery search to direct inspection.
- The hardening slice reduced duplicated policy reason text while preserving behavior-evaluation and snapshot coverage.
- Existing tests passed without representative example churn, confirming this was an internal policy-engine maintainability change rather than an output-contract change.

## Failure Signals Observed

- None in this task.

## Impact Judgment

effective

## Next Action

- Keep both changes observing until review; continue preferring small structured-policy cleanup where self-use exposes duplication or drift risk.
