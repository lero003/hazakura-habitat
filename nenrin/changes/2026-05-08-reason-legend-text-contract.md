---
type: nenrin_change
id: reason-legend-text-contract
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

# Change: reason-legend-text-contract

## Changed

- Added an output-contract test proving serialized `scan_result.json` command-reason text matches the text in the matching `policy.reasonCodes` legend entry.
- Included Review First command reasons in the same check so the short approval checklist cannot drift from the compact JSON legend.

## Reason

Agents and tools can consume `scan_result.json` without parsing `command_policy.md`. If `commandReasons.reason` and `policy.reasonCodes.text` diverge for the same reason code, the JSON contract becomes ambiguous and consumers may explain the same command risk inconsistently.

## Expected Behavior

- Future reason-text edits fail fast if command-reason metadata and legend metadata diverge.
- Output-contract hardening stays in `PolicyOutputContractTests.swift` rather than adding ecosystem-specific fixtures.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later reason-code wording changes update legend and command-reason metadata together.
- Machine consumers can treat `policy.reasonCodes` as the compact explanation map for command reasons.

## Failure Signals

- The schema intentionally allows per-command reason text to differ from the reason-code legend.
- Consumers stop using `policy.reasonCodes` as a compact map for command-reason explanations.

## Result

Unjudged.
