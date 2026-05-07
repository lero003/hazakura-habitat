---
type: nenrin_change
id: secret-file-policy-test-boundary
date: 2026-05-07
status: observing
impact: unknown
related_files:
  - Tests/HabitatCoreTests/SecretFilePolicyTests.swift
  - Tests/HabitatCoreTests/SecretFileDetectionTests.swift
  - docs/current_status.md
  - docs/roadmap.md
  - docs/self_use.md
review_after:
  tasks: 3
  days: 7
---

# Change: secret-file-policy-test-boundary

## Changed

- Moved detected secret-bearing file avoidance, recursive-search review, and project bulk-export policy scenarios into `SecretFilePolicyTests.swift`.
- Kept generated output, reason codes, scanner behavior, and secret detection semantics unchanged.

## Reason

Secret-file detection fixtures and generated command-policy contracts were sharing one large suite. Splitting the policy contracts keeps future search-shape or project-export safety edits close to the assertions that prove detected secret-bearing paths change the next command.

## Expected Behavior

- Future recursive-search, exclusion-glob, or project-export safety edits start from `SecretFilePolicyTests.swift`.
- `SecretFileDetectionTests.swift` stays focused on detection, unsafe metadata non-emission, symlink safety, package-auth path signals, and previous-scan secret deltas.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- A later search-shape or export-safety edit finds the relevant policy contract without searching the larger secret-file detection suite.
- The split preserves generated output and executable coverage.

## Failure Signals

- Detected secret-file policy assertions drift back into detection-only fixtures.
- A later suite move changes generated policy output or drops executable coverage.

## Result

Unjudged.
