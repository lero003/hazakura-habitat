---
type: nenrin_change
id: command-reason-coverage-contract
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

# Change: command-reason-coverage-contract

## Changed

- Added an output-contract test proving `scan_result.json` command-reason metadata stays one-to-one with generated Ask First and Forbidden commands.
- Covered both ordinary project policy and secret-bearing file policy without changing generated output.

## Reason

Agents can consume structured command reasons directly from JSON. If a future refactor duplicates, drops, or misclassifies a command reason while command counts still look plausible, the agent could attach approval reasoning to the wrong command.

## Expected Behavior

- Future policy metadata changes fail fast when command reasons stop covering exactly the classified command arrays.
- Output-contract hardening remains in `PolicyOutputContractTests.swift` instead of spreading into ecosystem-specific scanner fixtures.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later command-reason or reason-code edits reuse this one-to-one contract.
- No generated Markdown or representative example changes are needed for metadata-only hardening.

## Failure Signals

- The contract blocks an intentional schema change that decouples command reasons from command arrays.
- Review First metadata needs its own coverage model and this record is mistaken for covering it.

## Result

Unjudged.
