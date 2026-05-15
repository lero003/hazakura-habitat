---
type: nenrin_change
id: missing-wrapper-hint-contract
date: 2026-05-15
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/DocumentedValidationCommandEvidence.swift
  - Tests/HabitatCoreTests/InstructionAlignmentPolicyTests.swift
review_after:
  tasks: 3
  days: 7
---

# Change: missing-wrapper-hint-contract

## Changed

- Stopped `agent_context.md` from hinting that agents should prefer a documented
  project-local validation script when that script is missing or not executable.

## Reason

Current cross-project intake confirmed the known wrapper path is useful when it
is executable, but the existing missing-script fixture exposed a weaker output
contract: the short context avoided promoting the missing script in `Prefer`
while still saying to prefer it in Notes.

## Expected Behavior

- Executable project-local validation scripts can still be preferred.
- Missing or non-executable script claims remain bounded uncertainty and keep
  raw package-manager validation commands available.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Agents do not try a missing project-local script as the first validation
  command.
- Future wrapper-confidence work keeps the executable and missing-script cases
  separate.

## Failure Signals

- Missing script claims regain preference wording in Notes.
- Generic script uncertainty over-constrains raw package-manager validation even
  when the script cannot be executed.

## Result

Unjudged.
