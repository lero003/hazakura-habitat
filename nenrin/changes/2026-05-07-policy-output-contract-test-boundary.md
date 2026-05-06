---
type: nenrin_change
id: policy-output-contract-test-boundary
date: 2026-05-07
status: observing
impact: unknown
related_files:
  - Tests/HabitatCoreTests/PolicyOutputContractTests.swift
  - Tests/HabitatCoreTests/PackageAndCommandPolicyTests.swift
  - docs/current_status.md
  - docs/roadmap.md
  - docs/self_use.md
review_after:
  tasks: 3
  days: 7
---

# Change: policy-output-contract-test-boundary

## Changed

- Moved policy metadata, command-reason, older-JSON decoding, and reason-legend ordering checks into `PolicyOutputContractTests.swift`.
- Left scanner behavior, generated Markdown, `scan_result.json`, reason codes, and command ordering unchanged.

## Reason

`PackageAndCommandPolicyTests.swift` was carrying scanner fixtures and output-contract checks together. Splitting the policy output contract gives future generated-output work a smaller review surface without weakening behavior coverage.

## Expected Behavior

- Future policy metadata or reason-code rendering changes should update the output-contract suite instead of extending the larger package-manager scanner fixture file.
- The split should remain no-output-change.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Output-contract regressions point to a dedicated test suite.
- Future scanner fixture work does not need to parse unrelated command-reason metadata tests.

## Failure Signals

- The new suite starts accumulating package-manager behavior fixtures.
- Tests duplicate catalog-family classification contracts already owned by `PolicyReasonCatalogTests.swift`.

## Result

Unjudged.
