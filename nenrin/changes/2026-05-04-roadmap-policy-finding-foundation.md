---
type: nenrin_change
id: roadmap-policy-finding-foundation
date: 2026-05-04
status: observing
impact: unknown
related_files:
  - README.md
  - docs/roadmap.md
  - docs/current_status.md
  - docs/development_loop.md
  - CHANGELOG.md
review_after:
  tasks: 3
  days: 7
---

# Change: roadmap-policy-finding-foundation

## Changed

- Re-scoped `v0.4` from broad policy-engine hardening toward a thin Policy Finding Foundation.
- Moved full evidence normalization out of the `v0.4` exit gate and into later roadmap work.
- Reframed `v0.6` around the agent behavior feedback loop and `v0.7` around integration and distribution foundations.

## Reason

Post-`v0.3.0` work has already centralized command families and reason-code classification, but the code has not yet introduced the full `DetectedSignal -> NormalizedEvidence -> PolicyFinding -> RenderedOutput` pipeline. Treating that whole pipeline as `v0.4` would make release judgment too large and vague. A smaller Policy Finding Foundation target matches the current implementation direction and keeps the next release reviewable.

## Expected Behavior

- Future agents aim `v0.4` work at a visible `PolicyFinding`-like policy-decision core instead of broad scanner rewrites.
- Evidence-normalization ideas are deferred unless they are necessary to land the policy-finding foundation safely.
- Release discussion can judge `v0.4` by whether policy decisions are less duplicated and more renderer-independent.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- New `v0.4` slices stay small and policy-decision focused.
- Roadmap references no longer imply that full evidence normalization must ship before `v0.4`.
- The next release-readiness discussion has clearer completion criteria.

## Failure Signals

- Agents still try to complete the entire scanner-to-renderer pipeline before `v0.4`.
- Evidence normalization work expands without a measured command-decision need.
- Integration or distribution work starts before the policy-finding foundation has a clear release boundary.

## Result

Unjudged.
