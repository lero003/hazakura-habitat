---
type: nenrin_observation
id: policy-finding-command-reasons-003
date: 2026-05-04
related_changes:
  - policy-finding-command-reasons
  - local-git-workspace-command-family
impact_judgment: effective
success_tags:
  - changed_next_command
  - git_mutation_review
  - scoped_staging
  - avoided_evidence_normalization_expansion
failure_tags: []
---

# Observation: policy-finding-command-reasons-003

## Task

Run a post-v0.4 Habitat self-use observation slice and publish only the resulting behavior evidence and Nenrin record.

## Observed Behavior

- `agent_context.md` selected SwiftPM and kept dependency resolution behind Ask First.
- `command_policy.md` surfaced reason-coded `git_mutation` guidance before the long policy lists and annotated later Git staging, commit, and push commands.
- The next command path narrowed from routine broad staging to policy review, focused evidence recording, verification, and explicit-file staging.

## Success Signals Observed

- PolicyFinding-backed command reasons changed the publication path without needing new scanner facts.
- The agent checked existing evidence before editing, avoiding a duplicate policy or evidence-normalization change.
- The slice stayed observational: one behavior fixture, one docs index entry, one Nenrin observation, and metrics sync.

## Failure Signals Observed

- None observed in this slice.

## Impact Judgment

effective

## Next Action

- Keep observing Git and remote-repository publication decisions before promoting any scanner fact into normalized evidence.
