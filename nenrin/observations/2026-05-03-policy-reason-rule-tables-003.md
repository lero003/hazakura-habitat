---
type: nenrin_observation
id: policy-reason-rule-tables-003
date: 2026-05-03
related_changes:
  - policy-reason-rule-tables
  - remote-repository-action-reason-code
impact_judgment: effective
success_tags:
  - command_family_centralized
  - generated_output_preserved
failure_tags: []
---

# Observation: policy-reason-rule-tables-003

## Task

Post-v0.3 self-use automation slice for v0.4 policy-engine hardening.

## Observed Behavior

- The refreshed Habitat context kept work on SwiftPM verification and command-policy review before Git/GitHub mutation.
- Reading the long policy again showed that GitHub CLI command decisions depend on a stable local-vs-remote split.
- The implementation centralized the GitHub CLI mutation command family in `PolicyReasonCatalog`, so scanner command generation and reason-code classification consume the same source of truth.

## Success Signals Observed

- The change removed duplicated GitHub CLI command-family strings between scanning and reason classification.
- `swift test` passed with generated-output tests unchanged, confirming this was internal policy-engine hardening rather than an output-contract change.
- The next Git/GitHub command decision remains to inspect policy first, but future GitHub CLI additions have a narrower maintenance path.

## Failure Signals Observed

- None observed in this slice.

## Impact Judgment

effective

## Next Action

- Keep observing whether future command-family additions can stay centralized without turning the catalog into a broader policy DSL.
