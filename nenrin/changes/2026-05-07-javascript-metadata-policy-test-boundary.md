---
type: nenrin_change
id: javascript-metadata-policy-test-boundary
date: 2026-05-07
status: observing
impact: unknown
related_files:
  - Tests/HabitatCoreTests/JavaScriptMetadataPolicyTests.swift
  - docs/current_status.md
  - docs/roadmap.md
  - docs/self_use.md
review_after:
  tasks: 3
  days: 7
---

# Change: javascript-metadata-policy-test-boundary

## Changed

- Renamed the remaining package-policy catch-all suite to `JavaScriptMetadataPolicyTests.swift`.
- Kept generated output, reason codes, and scanner behavior unchanged.

## Reason

After the scenario-grouped test splits, the remaining `PackageAndCommandPolicyTests.swift` file only covered JavaScript scripts, package-manager metadata, runtime hints, and version-check guards. Naming that boundary directly reduces drift risk for future JavaScript metadata work and avoids reviving a generic catch-all suite.

## Expected Behavior

- Future JavaScript script, package-manager metadata, runtime hint, and version-check edits start from `JavaScriptMetadataPolicyTests.swift`.
- New command-decision coverage goes into a focused suite instead of recreating `PackageAndCommandPolicyTests.swift`.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- A later JavaScript metadata/version edit finds the relevant assertions without broad test-file search.
- Generated output remains stable across the rename.

## Failure Signals

- A new catch-all package-policy suite appears for unrelated scanner cases.
- JavaScript metadata tests are duplicated into selection or command-safety suites without a clear boundary.

## Result

Unjudged.
