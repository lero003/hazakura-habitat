---
type: nenrin_change
id: validation-claim-command-dedup
date: 2026-05-13
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/ProjectDetector.swift
  - Tests/HabitatCoreTests/InstructionAlignmentPolicyTests.swift
  - docs/current_status.md
  - docs/evaluation.md
review_after:
  tasks: 3
  days: 7
---

# Change: validation-claim-command-dedup

## Changed

- Collapsed duplicate documented validation-command claims by command, preserving the first source in instruction read order.

## Reason

Cross-project intake showed the same project-local validation script can appear in multiple docs. Repeating the same command in `scan_result.json` adds audit noise without changing the next command.

## Expected Behavior

- Agents see one sanitized validation claim for one command and keep using the same `agent_context.md` guidance.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Future scans keep validation-command evidence command-focused when docs repeat the same entrypoint.
- Multiple genuinely different validation workflows still produce bounded uncertainty.

## Failure Signals

- Useful source disagreement is hidden when commands differ.
- Duplicate command claims reappear in JSON and make freshness or instruction-alignment review noisier.

## Result

Unjudged.
