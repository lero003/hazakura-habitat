---
type: nenrin_change
id: review-first-reason-subset-contract
date: 2026-05-08
status: observing
impact: unknown
related_files:
  - Tests/HabitatCoreTests/PolicyOutputContractTests.swift
  - CHANGELOG.md
  - docs/current_status.md
  - docs/roadmap.md
  - docs/self_use.md
review_after:
  tasks: 3
  days: 7
---

# Change: review-first-reason-subset-contract

## Changed

- Added an output-contract test proving serialized `scan_result.json` Review First reason metadata stays within Ask First command reasons.
- Verified Review First reasons remain non-empty for a mixed SwiftPM/pnpm fixture, stay capped, use Ask First classification, and keep counts in sync.

## Reason

Agents can read `reviewFirstCommandReasons` as the short approval checklist without parsing `command_policy.md`. If Review First metadata drifts from Ask First command reasons, an agent could review the wrong reason or treat a non-Ask First command as needing approval.

## Expected Behavior

- Future Review First metadata edits fail fast when they stop being an ordered subset of Ask First command reasons.
- Output-contract hardening stays in `PolicyOutputContractTests.swift` rather than ecosystem-specific fixtures.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later Review First or command-reason changes reuse this subset contract.
- No generated Markdown or representative example changes are needed for metadata-only hardening.

## Failure Signals

- The schema intentionally decouples Review First from Ask First command reasons.
- The Review First checklist needs richer metadata than the current command/reason tuple.

## Result

Unjudged.
