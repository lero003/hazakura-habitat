---
type: nenrin_change
id: reason-legend-coverage-contract
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

# Change: reason-legend-coverage-contract

## Changed

- Added an output-contract test proving serialized `scan_result.json` reason-code legend metadata covers every command-reason code.
- Included Review First reason codes in the same coverage check so the short approval checklist cannot introduce an unlisted reason family.

## Reason

Agents can read `policy.reasonCodes` as the compact legend for `commandReasons` and `reviewFirstCommandReasons`. If a later metadata edit emits a command reason without a matching legend entry, the JSON contract becomes harder to consume without parsing rendered Markdown or duplicating catalog logic.

## Expected Behavior

- Future command-reason or Review First metadata edits fail fast when they emit reason codes not listed in `policy.reasonCodes`.
- Output-contract hardening remains in `PolicyOutputContractTests.swift` instead of ecosystem-specific fixtures.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later reason-code additions keep legend metadata and command-reason metadata synchronized.
- No generated Markdown or representative example changes are needed for metadata-only hardening.

## Failure Signals

- The schema intentionally decouples `policy.reasonCodes` from serialized command-reason metadata.
- Machine consumers stop treating `policy.reasonCodes` as the compact legend for command reasons.

## Result

Unjudged.
