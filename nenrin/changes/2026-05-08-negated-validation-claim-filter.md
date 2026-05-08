---
type: nenrin_change
id: negated-validation-claim-filter
date: 2026-05-08
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/ProjectDetector.swift
  - Tests/HabitatCoreTests/InstructionAlignmentPolicyTests.swift
  - CHANGELOG.md
  - docs/development_loop.md
  - docs/evaluation.md
  - docs/self_use.md
review_after:
  tasks: 3
  days: 7
---

# Change: negated-validation-claim-filter

## Changed

- Filtered negated, obsolete, deprecated, avoid, and example-only validation-command mentions out of positive documented validation claims.
- Added an instruction-alignment test proving `Do not run npm test; use swift test for validation.` records only the positive `swift test` claim.

## Reason

The post-`v0.5` instruction-alignment loop should not turn every command mention into guidance. A negated validation command changes the next command by telling the agent what not to follow; treating it as a positive claim would create false conflict or uncertainty.

## Expected Behavior

- Agents do not pause on a false `npm test` conflict when instructions explicitly reject it.
- Positive validation commands on the same line remain usable when repository facts support them.
- Raw instruction prose stays out of generated artifacts.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Future instruction-alignment slices distinguish command mentions from command claims.
- Agents still choose repository-supported validation commands when negated alternatives are present.

## Failure Signals

- The filter suppresses a real validation command because the line contains unrelated caution wording.
- More prose heuristics accumulate without a command-decision test.

## Result

Unjudged.
