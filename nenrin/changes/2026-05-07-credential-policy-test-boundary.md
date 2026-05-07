---
type: nenrin_change
id: credential-policy-test-boundary
date: 2026-05-07
status: observing
impact: unknown
related_files:
  - Tests/HabitatCoreTests/CredentialPolicyTests.swift
  - Tests/HabitatCoreTests/PackageAndCommandPolicyTests.swift
  - docs/current_status.md
  - docs/roadmap.md
  - docs/self_use.md
review_after:
  tasks: 3
  days: 7
---

# Change: credential-policy-test-boundary

## Changed

- Moved package-manager auth/config, CLI credential-store, and cloud/container credential policy scenarios into `CredentialPolicyTests.swift`.
- Kept generated output, reason codes, and scanner behavior unchanged.

## Reason

The remaining package-policy suite was still carrying credential-safety scenarios even though the command families already have catalog boundaries. A focused suite makes future credential-safety changes easier to verify without growing the general package-manager policy tests.

## Expected Behavior

- Future auth/session, package-manager config, or cloud/container credential edits start from `CredentialPolicyTests.swift`.
- `PackageAndCommandPolicyTests.swift` stays focused on remaining broad policy and JavaScript package-manager scenarios.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- A later credential-safety change finds the relevant contract quickly.
- Test moves continue to preserve output behavior and command reason codes.

## Failure Signals

- Credential-related assertions are duplicated back into the general package-policy suite.
- A future suite split drops executable coverage or changes generated policy output unintentionally.

## Result

Unjudged.
