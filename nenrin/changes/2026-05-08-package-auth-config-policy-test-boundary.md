---
type: nenrin_change
id: package-auth-config-policy-test-boundary
date: 2026-05-08
status: observing
impact: unknown
related_files:
  - Tests/HabitatCoreTests/PackageAuthConfigPolicyTests.swift
  - Tests/HabitatCoreTests/SecretFileDetectionTests.swift
  - docs/current_status.md
  - docs/roadmap.md
  - docs/self_use.md
review_after:
  tasks: 3
  days: 7
---

# Change: package-auth-config-policy-test-boundary

## Changed

- Moved npm, Python, Ruby, Cargo, and Composer package-auth config non-emission scenarios into `PackageAuthConfigPolicyTests.swift`.
- Kept generated output, reason codes, scanner behavior, and secret detection semantics unchanged.

## Reason

Package-auth config fixtures were still embedded in the broad secret-file detection suite. Splitting them gives credential-config edits a focused regression surface that proves Habitat detects auth config paths without emitting token values or sensitive config keys.

## Expected Behavior

- Future package-auth config detection or non-emission edits start from `PackageAuthConfigPolicyTests.swift`.
- `SecretFileDetectionTests.swift` stays focused on unsafe metadata non-emission, netrc/private-key detection, environment-file detection, and remaining secret-file signal cases.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- A later package credential config edit finds the relevant non-emission contracts without searching the larger secret-file detection suite.
- The split preserves generated output and executable coverage.

## Failure Signals

- Package-auth config assertions drift back into general secret-file detection fixtures.
- A later suite move changes generated policy output or drops executable coverage.

## Result

Unjudged.
