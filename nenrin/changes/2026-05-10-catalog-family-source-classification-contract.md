---
type: nenrin_change
id: catalog-family-source-classification-contract
date: 2026-05-10
status: observing
impact: unknown
related_files:
  - Tests/HabitatCoreTests/BaselineCommandCatalogTests.swift
  - docs/current_status.md
  - docs/roadmap.md
  - docs/self_use.md
review_after:
  tasks: 3
  days: 7
---

# Change: catalog-family-source-classification-contract

## Changed

- Added a `BaselineCommandCatalogTests` contract that checks catalog manifest sources against their command classification side.
- Allowed only the existing deliberate generic Ask First families to keep `user_approval_required` metadata.
- Preserved generated policy output, reason-code mapping, command order, and scanner behavior.

## Reason

The typed catalog manifest now declares whether each family is dynamic, baseline Ask First, or baseline Forbidden. That source label should remain tied to the command's actual policy side, or future catalog edits could make ownership look correct while routing a family through the wrong classification path.

## Expected Behavior

- Future manifest edits fail locally if a Forbidden family is registered on the Ask First side or an Ask First family loses its deliberate reason behavior.
- Agents keep seeing the same generated policy output while maintainers get earlier feedback on catalog drift.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- A future catalog-family move requires explicit review of source and reason behavior.
- No generated Markdown or JSON churn is needed for this contract.

## Failure Signals

- The contract becomes a noisy mirror of existing reason-routing tests without catching source drift.

## Result

Unjudged.
