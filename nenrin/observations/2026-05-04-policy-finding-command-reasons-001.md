---
type: nenrin_observation
id: policy-finding-command-reasons-001
date: 2026-05-04
related_changes:
  - policy-finding-command-reasons
impact_judgment: effective
success_tags:
  - policy-consumption
  - command-shape
failure_tags: []
---

# Observation: policy-finding-command-reasons-001

## Task

Post-v0.4 self-use automation on the Hazakura Habitat repository.

## Observed Behavior

- The fresh `agent_context.md` kept the work on SwiftPM validation and sent Git/GitHub mutation through `command_policy.md`.
- `command_policy.md` showed `git add`, `git commit`, and `git push` as `git_mutation`, while `scan_result.json` confirmed full reason-code coverage for policy commands.
- That changed the publication path from broad staging into policy review, verification, scoped diff inspection, and explicit-file staging.

## Success Signals Observed

- `PolicyFinding`-backed command reasons affected the next command sequence without changing generated output shape.
- No new scanner fact was needed before feeding policy or rendered output; this does not justify a broad normalized-evidence layer.

## Failure Signals Observed

- None observed.

## Impact Judgment

effective

## Next Action

- Keep observing whether `git_mutation` and `remote_repository_action` remain enough for self-use publication decisions before adding normalized evidence.
