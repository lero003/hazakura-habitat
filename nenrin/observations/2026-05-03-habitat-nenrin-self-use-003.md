---
type: nenrin_observation
id: habitat-nenrin-self-use-003
date: 2026-05-03
related_changes:
  - habitat-nenrin-self-use
  - nenrin-active-index-links
impact_judgment: effective
success_tags:
  - next_command_changed
  - active_index_link_used
  - discovery_search_avoided
failure_tags: []
---

# Observation: habitat-nenrin-self-use-003

## Task

Post-v0.3 self-use automation slice for Habitat, starting from the generated Habitat context and active Nenrin ledger.

## Observed Behavior

- Habitat context kept the command path on SwiftPM build/scan/test verification and policy review before Git mutation.
- `nenrin/index.md` listed active change ids with direct record links.
- The agent opened both active change records directly from the index instead of using repository-wide search to discover their paths.
- The cleanup choice stayed narrow: record the observation and make a small policy-reason maintainability change instead of adding more workflow guidance.

## Success Signals Observed

- The active index links changed the next command from discovery search to direct file inspection.
- The self-use ledger affected context gathering before file edits.
- The record uses behavior-level evidence and avoids raw prompts, secrets, shell history, clipboard contents, and credential material.

## Failure Signals Observed

- None in this task.

## Impact Judgment

effective

## Next Action

- Keep both changes observing until their scheduled review, but prefer direct active-record reads from the index in future automation runs.
