---
type: nenrin_change
id: command-reason-order-contract
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

# Change: command-reason-order-contract

## Changed

- Added an output-contract test proving serialized `scan_result.json` command-reason metadata mirrors the generated Ask First then Forbidden command order.
- Left scanner behavior, generated Markdown wording, command arrays, and reason-code mapping unchanged.

## Reason

Agents may use `scan_result.json` instead of parsing `command_policy.md`. If command reasons ever drift from the command arrays, a machine consumer could attach the wrong approval reason to a command or lose the rendered-policy order.

## Expected Behavior

- Future policy metadata refactors fail fast if `commandReasons` stops matching the generated command arrays.
- JSON consumers can keep reading command reasons as an ordered companion to Ask First and Forbidden commands.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later output-contract edits update `PolicyOutputContractTests.swift` instead of duplicating scanner fixtures.
- No generated Markdown or example output changes are needed for metadata-only hardening.

## Failure Signals

- The contract becomes too strict for an intentional future schema that separates command arrays from reason metadata.
- Command-reason drift appears through `reviewFirstCommandReasons`, which this contract does not directly govern.

## Result

Unjudged.
