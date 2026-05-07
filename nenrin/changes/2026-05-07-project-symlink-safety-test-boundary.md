---
type: nenrin_change
id: project-symlink-safety-test-boundary
date: 2026-05-07
status: observing
impact: unknown
related_files:
  - Tests/HabitatCoreTests/ProjectSymlinkSafetyTests.swift
  - Tests/HabitatCoreTests/SecretFileDetectionTests.swift
  - docs/current_status.md
  - docs/roadmap.md
  - docs/self_use.md
review_after:
  tasks: 3
  days: 7
---

# Change: project-symlink-safety-test-boundary

## Changed

- Moved symlinked project metadata, workflow, SSH directory, package-auth directory, and previous-scan symlink delta scenarios into `ProjectSymlinkSafetyTests.swift`.
- Kept generated output, reason codes, scanner behavior, and symlink detection semantics unchanged.

## Reason

Symlink-safety fixtures prove a distinct command-decision boundary: do not follow linked metadata or secret-bearing directories before reviewing targets. Giving those contracts a dedicated suite keeps future symlink handling changes out of broader secret-file detection fixtures.

## Expected Behavior

- Future symlink metadata, workflow selection, or previous-scan symlink delta edits start from `ProjectSymlinkSafetyTests.swift`.
- `SecretFileDetectionTests.swift` stays focused on direct secret-bearing file and unsafe metadata detection/non-emission contracts.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- A later symlink-safety edit finds the relevant policy and comparison contracts without searching the larger secret-file detection suite.
- The split preserves generated output and executable coverage.

## Failure Signals

- Symlink-policy assertions drift back into direct secret-file detection fixtures.
- A later suite move changes generated policy output or drops executable coverage.

## Result

Unjudged.
