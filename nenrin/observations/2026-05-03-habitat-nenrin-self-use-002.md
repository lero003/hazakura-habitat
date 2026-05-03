---
type: nenrin_observation
id: habitat-nenrin-self-use-002
date: 2026-05-03
related_changes:
  - habitat-nenrin-self-use
impact_judgment: partially_effective
success_tags:
  - next_command_changed
  - cleanup_choice_narrowed
failure_tags:
  - index_missing_active_record_links
---

# Observation: habitat-nenrin-self-use-002

## Task

Post-v0.3 self-use automation slice for Habitat, starting from a clean SwiftPM repository state and refreshed Habitat report.

## Observed Behavior

- Habitat context kept the command path on SwiftPM verification and policy review before Git mutation.
- The active Nenrin guidance caused the agent to read `nenrin/index.md` before choosing a slice.
- The index only reported the count of observing changes, so the agent used repository search to find the active change and prior observation records.
- After finding the records, the cleanup choice narrowed to improving Nenrin navigation instead of adding more broad workflow guidance.

## Success Signals Observed

- The active Nenrin change affected the order of context gathering before file edits.
- The task produced a concrete keep/narrow improvement: make the index point to active records directly.
- The record uses behavior-level evidence and avoids raw prompts, secrets, shell history, clipboard contents, and credential material.

## Failure Signals Observed

- The index did not identify the active change record, causing an avoidable exploratory search.

## Impact Judgment

partially_effective

## Next Action

- Keep the self-use change observing, but track whether active index links remove discovery searches in later tasks.
