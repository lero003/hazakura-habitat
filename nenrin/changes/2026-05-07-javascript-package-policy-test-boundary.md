---
type: nenrin_change
id: javascript-package-policy-test-boundary
date: 2026-05-07
status: observing
impact: unknown
related_files:
  - Tests/HabitatCoreTests/JavaScriptPackagePolicyTests.swift
  - Tests/HabitatCoreTests/PackageAndCommandPolicyTests.swift
review_after:
  tasks: 3
  days: 7
---

# Change: javascript-package-policy-test-boundary

## Changed

- Split JavaScript package-manager selection, Node/runtime guard, lockfile conflict, workspace, and package-manager field scanner policy scenarios into `JavaScriptPackagePolicyTests.swift`.
- Kept generated policy behavior unchanged while reducing `PackageAndCommandPolicyTests.swift`.

## Reason

JavaScript scanner selection still carries many command-decision cases: lockfile choice, runtime mismatch, missing preferred package-manager tools, workspace conflicts, and package-manager field pins. Giving these cases a local test owner makes future JavaScript command-decision work easier to verify without widening the general package-policy suite.

## Expected Behavior

- Future JavaScript package-manager selection and runtime-guard edits start in the dedicated suite.
- Agents can choose the narrow test owner for JavaScript scanner command decisions.
- No generated output, reason-code, or command-order behavior changes from this split alone.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later JavaScript selection or runtime-guard changes update `JavaScriptPackagePolicyTests.swift` directly.
- `PackageAndCommandPolicyTests.swift` stops accumulating JavaScript selection-only package-policy cases.
- `swift test` and the test-annotation contract keep coverage executable.

## Failure Signals

- New JavaScript selection, lockfile, workspace, or Node runtime cases are added back to `PackageAndCommandPolicyTests.swift`.
- The suite boundary causes duplicate fixtures or hides shared package-policy behavior.

## Result

Unjudged.
