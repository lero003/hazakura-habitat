---
type: nenrin_change
id: self-use-trigger-and-report-freshness
date: 2026-05-06
status: reviewed
impact: effective
related_files:
  - docs/self_use.md
  - docs/development_loop.md
  - docs/current_status.md
review_after:
  tasks: 3
  days: 7
---

# Change: self-use-trigger-and-report-freshness

## Changed

- Added concrete examples for when Habitat self-use scans should run and when they can be skipped.
- Clarified that `habitat-report/` is a working snapshot to regenerate when repository facts, guidance, public baseline, or risky command decisions depend on current state.
- Added the Habitat-to-Nenrin handoff pattern without storing raw scan output in Nenrin.
- Added report freshness guidance to the current cycle without turning stale-report cleanup into an immediate product feature.

## Reason

BBS feedback from Chika's Habitat improvement thread identified three ambiguous operating points: scan trigger thresholds, generated report freshness, and the Habitat plus Nenrin handoff. The existing docs already had the right principle, but they left agents to infer too much from "substantial work" and "do not commit habitat-report".

## Expected Behavior

- Agents choose Habitat scans for high-impact or current-fact-sensitive work and skip them for low-risk edits when existing guidance is enough.
- Old local reports are not treated as durable source material.
- Nenrin records behavior-level reasons for agent-facing changes instead of copying scanner output.
- Future product work starts from a measured stale-report or trigger failure before adding automatic cleanup or richer report lifecycle features.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- A later automation run can explain why it did or did not regenerate `habitat-report/`.
- A later BBS or review discussion treats automatic stale-report cleanup as conditional on observed agent mistakes.
- Nenrin entries for self-use changes keep recording decision impact rather than raw report contents.

## Failure Signals

- Agents still treat every small edit as requiring a scan.
- Agents reuse stale `habitat-report/` output after package-manager, release, secret, or generated-output facts changed.
- Nenrin becomes a duplicate archive of scan output.

## Result

Unjudged.
