---
type: nenrin_change
id: policy-reason-catalog-test-boundary
date: 2026-05-06
status: observing
impact: unknown
related_files:
  - Tests/HabitatCoreTests/PolicyReasonCatalogTests.swift
  - Tests/HabitatCoreTests/PackageAndCommandPolicyTests.swift
  - docs/current_status.md
  - docs/roadmap.md
review_after:
  tasks: 3
  days: 7
---

# Change: policy-reason-catalog-test-boundary

## Changed

- Moved the catalog-family classification preservation contract into `PolicyReasonCatalogTests.swift`.
- Left scanner behavior, generated Markdown, `scan_result.json`, reason codes, and command ordering unchanged.

## Reason

The package and command policy suite was accumulating two responsibilities: scanner behavior fixtures and catalog-family contract coverage. Keeping the catalog contract in a dedicated suite makes future command-family slices easier to review without weakening coverage.

## Expected Behavior

- Future catalog-family edits should update one classification contract suite instead of extending the larger package/scanner fixture file.
- The split should remain no-output-change.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later command-family slices find the classification contract faster.
- Test failures point to catalog reason-code drift more directly.

## Failure Signals

- The new suite becomes a dumping ground for scanner behavior fixtures.
- Tests duplicate assertions already owned by package-manager scenario coverage.

## Result

Unjudged.
