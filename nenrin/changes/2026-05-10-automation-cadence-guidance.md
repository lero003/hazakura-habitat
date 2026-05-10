---
type: nenrin_change
id: automation-cadence-guidance
date: 2026-05-10
status: observing
impact: unknown
related_files:
  - docs/development_loop.md
review_after:
  tasks: 3
  days: 7
---

# Change: automation-cadence-guidance

## Changed

- Replaced the fixed one-hour automation cadence wording with adjustable cadence guidance.
- Clarified that lower-frequency post-release observation is appropriate when recent slices mostly confirm stable behavior.
- Kept the completion standard on one coherent, verified development slice per run.

## Reason

The current Habitat automation is intentionally low-frequency. The old wording made one hour sound like the default operating contract, which could push agents toward unnecessary work when the useful command-decision gap is not yet clear.

## Expected Behavior

- Future automation treats cadence as an operational choice, not a product milestone.
- Low-frequency runs still choose one complete, verifiable slice instead of broad exploration.
- Cadence increases only when fresh evidence shows tighter feedback would change command choice or close a concrete risk.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later runs do not manufacture work just to fill a one-hour loop.
- Cadence changes are tied to observed command-decision, release, safety, or output-contract risk.

## Failure Signals

- Automation interprets low frequency as permission to skip verification.
- Automation increases cadence without a concrete risk or command-decision benefit.

## Result

Unjudged.
