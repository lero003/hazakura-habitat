---
type: nenrin_change
id: package-registry-policy-test-boundary
date: 2026-05-07
status: observing
impact: unknown
related_files:
  - Tests/HabitatCoreTests/PackageRegistryPolicyTests.swift
  - Tests/HabitatCoreTests/PackageAndCommandPolicyTests.swift
review_after:
  tasks: 3
  days: 7
---

# Change: package-registry-policy-test-boundary

## Changed

- Split ephemeral package execution and package-registry mutation scanner policy scenarios into `PackageRegistryPolicyTests.swift`.
- Kept generated policy behavior unchanged while reducing `PackageAndCommandPolicyTests.swift`.

## Reason

Package execution and package publication commands are command-risk boundaries that cut across language ecosystems. Giving them a local test owner makes future `npx`/`dlx`/`uvx`, publish, owner, dist-tag, and yank edits easier to verify without widening the general package-policy suite.

## Expected Behavior

- Future ephemeral package execution and package-registry mutation edits start in the dedicated suite.
- Agents can choose the narrow test owner for registry and ephemeral execution command decisions.
- No generated output, reason-code, or command-order behavior changes from this split alone.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later package-registry or ephemeral execution changes update `PackageRegistryPolicyTests.swift` directly.
- `PackageAndCommandPolicyTests.swift` stops accumulating registry-only package-policy cases.
- `swift test` and the test-annotation contract keep coverage executable.

## Failure Signals

- New publish, owner, dist-tag, yank, `npx`, `dlx`, `uvx`, or `pipx run` cases are added back to `PackageAndCommandPolicyTests.swift`.
- The suite boundary causes duplicate fixtures or hides shared package-policy behavior.

## Result

Unjudged.
