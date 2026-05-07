---
type: nenrin_change
id: python-package-policy-test-boundary
date: 2026-05-07
status: observing
impact: unknown
related_files:
  - Tests/HabitatCoreTests/PythonPackagePolicyTests.swift
  - Tests/HabitatCoreTests/PackageAndCommandPolicyTests.swift
review_after:
  tasks: 3
  days: 7
---

# Change: python-package-policy-test-boundary

## Changed

- Split Python, pip, uv, virtual-environment, and Python runtime-hint scanner policy scenarios into `PythonPackagePolicyTests.swift`.
- Kept generated policy behavior unchanged while reducing `PackageAndCommandPolicyTests.swift`.

## Reason

Python and uv command decisions already have catalog-owned policy boundaries. Their scanner contracts should have the same local test owner so future Python, pip, uv, virtual-environment, or runtime-hint edits can be verified without searching the larger package-policy suite.

## Expected Behavior

- Future Python and uv scanner or policy edits start in the dedicated suite.
- Agents can choose the narrow test owner for Python package-manager command decisions.
- No generated output, reason-code, or command-order behavior changes from this split alone.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later Python or uv changes update `PythonPackagePolicyTests.swift` directly.
- `PackageAndCommandPolicyTests.swift` stops accumulating Python-only package-policy cases.
- `swift test` and the test-annotation contract keep coverage executable.

## Failure Signals

- New Python, pip, uv, or virtual-environment cases are added back to `PackageAndCommandPolicyTests.swift`.
- The suite boundary causes duplicate fixtures or hides shared JavaScript/Python package-manager behavior.

## Result

Unjudged.
