---
type: nenrin_observation
id: host-private-command-family-001
date: 2026-05-04
related_changes:
  - host-private-command-family
impact_judgment: effective
success_tags:
  - policy-consumption
  - host-private-avoidance
failure_tags: []
---

# Observation: host-private-command-family-001

## Task

Post-v0.3 self-use automation on the Hazakura Habitat repository.

## Observed Behavior

- The generated `agent_context.md` surfaced host-private Do Not guidance for environment dumps, clipboard reads, shell history, browser profiles, and local mail.
- That guidance kept context gathering on project-local docs, `rg`, and SwiftPM verification rather than host-private inspection.
- The full `command_policy.md` still exposed the host-private reason family before long policy lists, so no extra policy lookup was needed to avoid those command shapes.

## Success Signals Observed

- Host-private guidance affected the next-command boundary by excluding environment, clipboard, shell-history, browser, and mail reads from context gathering.
- The agent kept useful read-only project inspection available instead of over-banning source and docs reads.

## Failure Signals Observed

- None observed.

## Impact Judgment

effective

## Next Action

- Keep the host-private command family active; watch for over-broad classification only when future policy additions touch project-local inspection.
