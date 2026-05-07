---
type: nenrin_change
id: javascript-command-policy-test-boundary
date: 2026-05-07
status: observing
impact: unknown
related_files:
  - Tests/HabitatCoreTests/JavaScriptCommandPolicyTests.swift
  - Tests/HabitatCoreTests/PackageAndCommandPolicyTests.swift
  - docs/current_status.md
  - docs/roadmap.md
  - docs/self_use.md
review_after:
  tasks: 3
  days: 7
---

# Change: javascript-command-policy-test-boundary

## Changed

- Moved JavaScript missing-tool, dependency-mutation, global-install, and Corepack command-safety scenarios into `JavaScriptCommandPolicyTests.swift`.
- Kept generated output, reason codes, and scanner behavior unchanged.

## Reason

`PackageAndCommandPolicyTests.swift` still mixed JavaScript command-safety contracts with broad policy checks and JavaScript metadata/version scenarios. A focused suite gives future JavaScript command-policy edits a smaller starting point without expanding scanner behavior.

## Expected Behavior

- Future JavaScript missing-tool, install/update/remove, global package mutation, or Corepack policy edits start from `JavaScriptCommandPolicyTests.swift`.
- `PackageAndCommandPolicyTests.swift` continues shrinking around remaining broad policy and JavaScript metadata/version contracts.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- A later JavaScript command-policy change finds the relevant contract quickly.
- Test moves continue to preserve output behavior and command reason codes.

## Failure Signals

- JavaScript command-safety assertions are duplicated back into the general package-policy suite.
- A future suite split drops executable coverage or changes generated policy output unintentionally.

## Result

Unjudged.
