---
type: nenrin_change
id: markdown-reason-legend-contract
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

# Change: markdown-reason-legend-contract

## Changed

- Added an output-contract test proving `command_policy.md` `Reason Codes` bullet lines match the serialized `policy.reasonCodes` metadata exactly.
- Kept the check in `PolicyOutputContractTests.swift` because this is a rendered-output contract, not a package-manager fixture.

## Reason

Agents may read either `command_policy.md` or `scan_result.json` depending on the command risk. If the Markdown legend drifts from JSON metadata, the same reason code can explain a command differently across the two AI-facing surfaces.

## Expected Behavior

- Future reason-code wording or ordering changes update Markdown and JSON together.
- The compact Markdown policy remains a trustworthy human-readable view of the same metadata machine consumers read.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later reason-code edits fail fast when the Markdown legend and serialized metadata diverge.
- Agents can switch between `command_policy.md` and `scan_result.json` without seeing inconsistent command-risk explanations.

## Failure Signals

- The generated Markdown intentionally diverges from `policy.reasonCodes`.
- Reason-code presentation changes require a broader schema or renderer design instead of a direct sync contract.

## Result

Unjudged.
