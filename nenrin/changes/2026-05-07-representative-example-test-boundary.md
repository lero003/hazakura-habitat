---
type: nenrin_change
id: representative-example-test-boundary
date: 2026-05-07
status: observing
impact: unknown
related_files:
  - Tests/HabitatCoreTests/RepresentativeExampleTests.swift
  - Tests/HabitatCoreTests/HabitatCoreTests.swift
  - docs/current_status.md
  - docs/roadmap.md
  - docs/self_use.md
review_after:
  tasks: 3
  days: 7
---

# Change: representative-example-test-boundary

## Changed

- Moved representative generated example and artifact metadata checks into `RepresentativeExampleTests.swift`.
- Kept generated output, example contents, scanner behavior, reason codes, and fixture semantics unchanged.

## Reason

Representative examples are an AI-facing contract: they prove the checked-in `agent_context.md`, `command_policy.md`, and artifact metadata still match the current output shape. Giving those checks a dedicated suite keeps future example-output drift work out of the broader core infrastructure tests.

## Expected Behavior

- Future generated example or artifact metadata changes start from `RepresentativeExampleTests.swift`.
- `HabitatCoreTests.swift` stays focused on parser, command-runner, report-writer, and core output behavior.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- A later example-output edit finds the representative fixture contracts without searching the core infrastructure suite.
- The split preserves generated output and executable coverage.

## Failure Signals

- Example drift assertions move back into unrelated core infrastructure tests.
- A later example change updates fixtures without the representative suite catching metadata or reading-contract drift.

## Result

Unjudged.
