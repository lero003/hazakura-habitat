---
type: nenrin_change
id: operational-intuition-readme-framing
date: 2026-05-16
status: observing
impact: unknown
related_files:
  - README.md
  - docs/product_direction.md
  - CHANGELOG.md
review_after:
  tasks: 3
  days: 7
---

# Change: operational-intuition-readme-framing

## Changed

- Clarified README and product-direction wording so Habitat is framed as
  evidence-backed, bounded first-pass repository guidance for AI agents.
- Made the narrow scope explicit: Habitat encodes reusable command-decision
  patterns from visible repository facts, not broad language or environment
  expertise.

## Reason

The project had strong technical docs for pre-execution context, but the public
entrypoint could still read like an instructional checklist. The user clarified
that the stronger product idea is closer to a veteran maintainer's first-pass
read: infer likely entrypoints and risks from repository evidence, then prefer,
ask, refuse, or downgrade stale context without overclaiming.

## Expected Behavior

- Future readers understand why Habitat can be narrow while still useful across
  different macOS-local repositories.
- Agents do not treat SwiftPM/macOS depth as a promise of broad ecosystem
  support.
- Future feature proposals stay tied to command-decision patterns rather than
  environment inventory or language coverage.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- README-driven discussions describe Habitat as evidence-backed, bounded
  first-pass repo guidance rather than a scanner checklist or language-support
  matrix.
- Future cross-project observations ask whether a pattern changes command
  choice before adding ecosystem-specific depth.

## Failure Signals

- Readers still ask whether Habitat is trying to become a broad language or
  environment expert.
- New docs imply intuition without repository evidence or bounded uncertainty.

## Result

Unjudged.
