---
type: nenrin_change
id: baseline-unowned-command-contract
date: 2026-05-09
status: observing
impact: unknown
related_files:
  - Tests/HabitatCoreTests/PolicyReasonCatalogTests.swift
  - docs/current_status.md
  - docs/roadmap.md
  - docs/self_use.md
review_after:
  tasks: 3
  days: 7
---

# Change: baseline-unowned-command-contract

## Changed

- Added a `PolicyReasonCatalogTests` contract requiring every static baseline Ask First and Forbidden command to belong to a named catalog family or an explicit static guard.

## Reason

Baseline policy assembly has enough command families that a direct ad hoc append could bypass the intended owner boundary. That would make future reason-code drift harder to notice before generated policy changes.

## Expected Behavior

- Future baseline policy edits either use an existing catalog family, create a clear new family, or update the explicit static guard list.
- The curated baseline remains auditable without adding broad command-catalog infrastructure.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- A later baseline policy addition fails tests until its ownership boundary is made explicit.
- Generated policy changes stay tied to reviewed catalog families rather than hidden ad hoc entries.

## Failure Signals

- The contract becomes noisy when a genuinely one-off static guard is appropriate.
- Future contributors duplicate ownership lists instead of moving a command into the right family.

## Result

Unjudged.
