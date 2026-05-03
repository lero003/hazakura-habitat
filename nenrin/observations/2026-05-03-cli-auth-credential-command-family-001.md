---
type: nenrin_observation
id: cli-auth-credential-command-family-001
date: 2026-05-03
related_changes:
  - cli-auth-credential-command-family
impact_judgment: effective
success_tags:
  - command_family_pattern_reused
  - cleanup_choice_improved
failure_tags: []
---

# Observation: cli-auth-credential-command-family-001

## Task

Post-v0.3 self-use automation slice for v0.4 policy-engine hardening.

## Observed Behavior

- The refreshed Habitat context kept the next command decision on SwiftPM verification and pointed Git/GitHub mutation review to `command_policy.md`.
- Reading the long policy showed credential/session forbids are now precise enough to reveal adjacent duplication: cloud/container credential entries were generated in `Scanner` while reason classification still relied on separate auth-prefix criteria.
- The prior CLI auth/credential command-family change affected the cleanup choice by making the same one-family pattern the smallest safe refactor for adjacent credential policy.

## Success Signals Observed

- The next cleanup stayed narrow: one generated Forbidden command family moved into `PolicyReasonCatalog` without adding a new policy abstraction.
- The focused test now consumes the centralized family, matching the prior CLI auth/credential pattern.
- Generated output is intended to remain unchanged, preserving the v0.3 behavior evidence.

## Failure Signals Observed

- None observed in this slice.

## Impact Judgment

effective

## Next Action

- Keep using this pattern only for command families where policy review exposes duplicated ownership; avoid broad cloud/container expansion.
