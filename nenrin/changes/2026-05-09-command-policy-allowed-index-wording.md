---
type: nenrin_change
id: command-policy-allowed-index-wording
date: 2026-05-09
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/ReportWriter.swift
  - Tests/HabitatCoreTests/CoreInfrastructureTests.swift
  - examples/swift-package/command_policy.md
  - examples/secret-bearing-files/command_policy.md
  - CHANGELOG.md
review_after:
  tasks: 3
  days: 7
---

# Change: command-policy-allowed-index-wording

## Changed

- Changed the `command_policy.md` `Policy Index` `Allowed` summary from "concrete safe starting point(s)" to "safe starting point(s)".
- Updated generated examples and output-contract expectations for the wording.

## Reason

The Allowed section can include command families such as read-only project inspection, not only concrete commands. The old wording overstated the precision of the index and could make agents treat broad read-only inspection guidance as a literal command list.

## Expected Behavior

- Agents continue to use the Allowed section as safe starting guidance without assuming every entry is a concrete executable command.
- Future policy index wording stays aligned with the rendered section contents.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later generated-policy changes avoid over-specific index wording when a section contains command families or guidance lines.
- Representative examples keep the index wording synchronized with actual generated output.

## Failure Signals

- Agents still mistake Allowed guidance lines for exact commands to run.
- The index becomes vague enough that agents need to scan the full policy for ordinary safe starts.

## Result

Unjudged.
