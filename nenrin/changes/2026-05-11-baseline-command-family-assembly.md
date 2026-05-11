---
type: nenrin_change
id: baseline-command-family-assembly
date: 2026-05-11
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/PolicyReasonCatalog+BaselinePolicy.swift
  - Sources/HabitatCore/PolicyReasonCatalog+CommandFamilies.swift
  - Tests/HabitatCoreTests/BaselineCommandCatalogTests.swift
  - docs/current_status.md
  - docs/roadmap.md
review_after:
  tasks: 3
  days: 7
---

# Change: baseline-command-family-assembly

## Changed

- Added `baselineCommandFamilies` as the combined baseline Ask First and Forbidden command-family boundary.
- Updated catalog assembly to join dynamic Ask First families with that combined baseline boundary.
- Updated baseline catalog tests to use the same boundary and to catch duplicate family names across baseline policy sides.

## Reason

The baseline Ask First and Forbidden partitions were already source-labeled, but call sites still hand-joined them in several places. A named combined boundary makes future catalog maintenance start from the same assembly shape that generated policy and drift tests use.

## Expected Behavior

- Generated `agent_context.md`, `command_policy.md`, and `scan_result.json` remain unchanged.
- Future baseline family edits use one combined baseline manifest boundary before joining with dynamic Ask First families.
- Cross-side duplicate family names fail in the catalog test suite.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later baseline catalog edits reuse `baselineCommandFamilies` instead of hand-joining policy sides.
- Catalog drift tests stay focused on command-family ownership rather than duplicated assembly logic.

## Failure Signals

- The added boundary becomes another redundant name without improving review clarity.
- Future catalog edits bypass the combined baseline manifest and reintroduce local joins.

## Result

Unjudged.
