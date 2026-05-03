---
type: nenrin_observation
id: habitat-nenrin-self-use-004
date: 2026-05-03
related_changes:
  - habitat-nenrin-self-use
  - nenrin-active-index-links
impact_judgment: effective
success_tags:
  - next_command_changed
  - active_index_link_used
  - policy_structure_hardened
failure_tags: []
---

# Observation: habitat-nenrin-self-use-004

## Task

Post-v0.3 self-use automation slice for Habitat, using the refreshed generated Habitat context before v0.4 policy-engine hardening.

## Observed Behavior

- Habitat context kept the next substantial commands on SwiftPM verification, self-scan refresh, and read-only source inspection before code edits.
- `nenrin/index.md` again provided direct active change links, so the agent opened the relevant change records without repository-wide discovery search.
- The self-use signal pointed to a concrete v0.4 maintainability gap: Markdown policy rendering still recomputed reason codes from command strings even though `scan_result.json` already carried structured `policy.commandReasons` and `policy.reasonCodes`.
- The implemented response stayed narrow: make `ReportWriter` consume structured reason metadata first, preserve catalog fallback for older/minimal scans, and centralize the reason classification tokens.

## Success Signals Observed

- Active Nenrin links affected the context-gathering command path.
- Generated policy behavior stayed stable for normal scans while renderer ownership moved toward structured policy data.
- The observation records behavior-level impact without raw prompts, secrets, shell history, clipboard contents, or credential material.

## Failure Signals Observed

- None in this task.

## Impact Judgment

effective

## Next Action

- Keep both changes observing until review; future slices should continue preferring structured policy data over renderer-side recomputation when it reduces duplication.
