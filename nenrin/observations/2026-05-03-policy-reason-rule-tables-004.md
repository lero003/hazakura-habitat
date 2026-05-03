---
type: nenrin_observation
id: policy-reason-rule-tables-004
date: 2026-05-03
related_changes:
  - policy-reason-rule-tables
impact_judgment: effective
success_tags:
  - command_family_centralized
  - generated_output_preserved
failure_tags: []
---

# Observation: policy-reason-rule-tables-004

## Task

Post-v0.3 self-use automation slice for v0.4 policy-engine hardening.

## Observed Behavior

- The refreshed Habitat context kept this repository on SwiftPM verification and allowed read-only `rg` inspection in a repository with no secret-bearing file signals.
- Inspecting the long policy showed `ephemeral_package_execution` remains a visible command-decision reason in the short overflow summary and full policy legend.
- The implementation centralized the ephemeral package execution command family in `PolicyReasonCatalog`, so scanner command generation and reason-code classification consume the same source of truth while preserving command order.

## Success Signals Observed

- The change removed duplicated `npx`, `dlx`, `uvx`, and `pipx run` command-family strings between scanning and reason classification.
- Generated output is expected to stay unchanged because Scanner still emits the shared subfamilies at their original positions.
- Future ephemeral package execution additions have a narrower maintenance path and should not require renderer logic changes.

## Failure Signals Observed

- None observed in this slice.

## Impact Judgment

effective

## Next Action

- Keep centralizing command families only when self-use exposes a real command-decision or maintenance risk; avoid creating a custom policy DSL.
