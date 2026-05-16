---
type: nenrin_change
id: previous-scan-unreadable-boundary
date: 2026-05-16
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/PreviousScanComparison.swift
  - Sources/habitat-scan/main.swift
  - Tests/HabitatCoreTests/ScanComparisonTests.swift
  - docs/current_status.md
review_after:
  tasks: 3
  days: 7
---

# Change: previous-scan-unreadable-boundary

## Changed

- Moved unreadable `--previous-scan` handling into a small Core boundary.
- Pinned the fallback as a `scan_comparison` change that tells agents to rely on the current command policy until comparison succeeds.

## Reason

Pre-1.0 hardening needs failure-mode contracts as much as successful deltas. A missing, corrupt, or wrong-path previous report should not fail the current scan, and it should not make agents trust stale comparison data.

## Expected Behavior

- Agents see bounded uncertainty when previous-scan input cannot be read.
- Current `agent_context.md` and `command_policy.md` remain the authority for command decisions.
- Future CLI or helper refactors reuse the same Core fallback instead of duplicating untested wording.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Future previous-scan failure cases continue to surface as concise `scan_comparison` notes.
- Agents do not hand-compare or trust a broken saved report after the fallback appears.

## Failure Signals

- A helper or CLI path turns unreadable previous scans into fatal failures.
- Agents treat the fallback as proof that the previous report was successfully compared.

## Result

Unjudged.
