---
type: nenrin_change
id: pip-cache-removal-reason
date: 2026-05-11
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/PolicyReasonCatalog+PythonPackageManager.swift
  - Sources/HabitatCore/PolicyReasonCatalog+ReasonRules.swift
  - Tests/HabitatCoreTests/BaselineCommandCatalogTests.swift
  - Tests/HabitatCoreTests/PolicyReasonCatalogTests.swift
  - examples/behavior-evaluation/swiftpm-self-use-017.json
review_after:
  tasks: 3
  days: 7
---

# Change: pip-cache-removal-reason

## Changed

- Kept `pip cache remove` aliases in the baseline Ask First catalog.
- Stopped routing those cache-removal commands through dependency-mutation reason metadata.
- Added self-use behavior evidence for the narrower reason-code boundary.

## Reason

`pip cache remove` changes local pip cache state and deserves approval, but it does not install, update, remove, or resolve project dependencies. The previous reason text overstated the command-decision risk.

## Expected Behavior

- Agents still pause before pip cache removal.
- Generated command reasons describe the command as generic approval instead of dependency mutation.
- Future Python package-manager edits can distinguish dependency mutation from cache cleanup.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- A later Python policy edit keeps cache cleanup behind approval without reintroducing dependency-mutation wording.
- No generated policy count or ordering drift appears from this reason-code narrowing.

## Failure Signals

- The generic approval metadata is too vague for future pip cache cleanup decisions.
- The separate behavior fixture adds review weight without changing a later command decision.
