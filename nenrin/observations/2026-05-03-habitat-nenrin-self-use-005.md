---
type: nenrin_observation
id: habitat-nenrin-self-use-005
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

# Observation: habitat-nenrin-self-use-005

## Task

Post-v0.3 self-use automation slice for v0.4 policy-engine hardening.

## Observed Behavior

- Habitat context kept the next substantial commands on SwiftPM verification, self-scan refresh, and policy review before code edits or Git mutation.
- `nenrin/index.md` exposed active change links, so the agent opened active records directly and avoided repository-wide discovery just to find the current Nenrin context.
- The self-use signal extended the previous structured-policy renderer finding: `agent_context.md` Ask First overflow summaries still recomputed reason-code families from command strings.
- The implemented response stayed narrow: the short-context overflow summary now consumes structured `policy.commandReasons` and `policy.reasonCodes` first, with the existing catalog fallback retained for older scans.

## Success Signals Observed

- Active Nenrin links affected the context-gathering command path.
- Renderer ownership moved further toward structured policy data without changing normal generated output.
- A focused regression test now proves hidden Ask First overflow summaries honor scan-supplied reason metadata.

## Failure Signals Observed

- None in this task.

## Impact Judgment

effective

## Next Action

- Keep both changes observing until review; continue moving renderer decisions to structured policy metadata only where it removes concrete duplication.
