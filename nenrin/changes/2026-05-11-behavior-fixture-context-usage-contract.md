---
type: nenrin_change
id: behavior-fixture-context-usage-contract
date: 2026-05-11
status: observing
impact: unknown
related_files:
  - Tests/HabitatCoreTests/BehaviorEvidenceSanitizationTests.swift
  - docs/evaluation.md
  - docs/current_status.md
  - docs/roadmap.md
review_after:
  tasks: 3
  days: 7
---

# Change: behavior-fixture-context-usage-contract

## Changed

- Added a behavior-evidence contract that fixture `caseId` values stay unique.
- Added a behavior-evidence contract that each fixture records whether Habitat context or policy shaped the observed behavior.
- Updated evaluation and status docs to name this fixture-quality boundary.

## Reason

Behavior fixtures should remain command-decision evidence, not just archived anecdotes. If two fixtures share a case ID or a fixture does not state that Habitat context or policy affected the behavior, future agents can mistake weak evidence for a new normalized-evidence gap.

## Expected Behavior

- Future fixture additions fail fast when they omit the link between Habitat output and the observed command choice.
- Agents can trust fixture IDs as stable references in docs and reviews.
- Quiet self-use runs remain acceptable, but only when the fixture still records the command-decision effect.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- New behavior fixtures include unique IDs and explicit context or policy usage evidence.
- Later agents cite existing fixture evidence before adding overlapping evidence-normalization work.

## Failure Signals

- The contract encourages mechanical flags that do not describe a real command-decision effect.
- Behavior fixtures continue growing when a no-op report would be clearer.

## Result

Unjudged.
