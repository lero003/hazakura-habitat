---
type: nenrin_observation
id: package-registry-reason-code-001
date: 2026-05-03
related_changes:
  - package-registry-reason-code
  - policy-reason-rule-tables
impact_judgment: effective
success_tags:
  - command_family_centralized
  - generated_output_preserved
failure_tags: []
---

# Observation: package-registry-reason-code-001

## Task

Post-v0.3 self-use automation slice for v0.4 policy-engine hardening.

## Observed Behavior

- The refreshed Habitat context kept the next safe command decision on SwiftPM verification and policy review before Git/GitHub mutation.
- Reading the long policy showed `package_registry_mutation` still matters in the short-context overflow and full-policy reason legend.
- The active Nenrin change named duplicated package-registry command matching outside `PolicyReasonCatalog` as a failure signal, and the scanner still hard-coded the same publication and registry metadata command family.
- The implementation centralized package-registry mutation commands in `PolicyReasonCatalog`, so scanner command generation and reason-code classification consume the same source of truth.

## Success Signals Observed

- The change removed duplicated package-registry command-family strings between scanning and reason classification.
- Generated output behavior remains intended to stay unchanged: publication, owner, dist-tag, yank, and trunk commands still require Ask First with `package_registry_mutation`.
- Future package-registry command additions have a narrower maintenance path that does not require parallel scanner and classifier edits.

## Failure Signals Observed

- None observed in this slice.

## Impact Judgment

effective

## Next Action

- Keep observing whether package-registry additions attach to the centralized command family without introducing renderer-specific policy logic.
