---
type: nenrin_change
id: host-private-data-policy-test-boundary
date: 2026-05-07
status: observing
impact: unknown
related_files:
  - Tests/HabitatCoreTests/HostPrivateDataPolicyTests.swift
  - Tests/HabitatCoreTests/SecretFileDetectionTests.swift
  - docs/current_status.md
  - docs/roadmap.md
  - docs/self_use.md
review_after:
  tasks: 3
  days: 7
---

# Change: host-private-data-policy-test-boundary

## Changed

- Moved environment dump, clipboard, shell history, browser/mail data, and home SSH private-key command policy scenarios into `HostPrivateDataPolicyTests.swift`.
- Kept generated output, reason codes, and scanner behavior unchanged.

## Reason

`SecretFileDetectionTests.swift` was carrying both project secret-bearing file detection and host-private command policy contracts. Splitting host-private command safety into its own suite keeps future clipboard/history/browser/mail/private-key policy edits close to the relevant assertions without expanding the project secret-file fixture file.

## Expected Behavior

- Future host-private command-safety edits start from `HostPrivateDataPolicyTests.swift`.
- `SecretFileDetectionTests.swift` stays focused on detected project secret-bearing paths, unsafe metadata non-emission, symlink safety, and secret-file comparison signals.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- A later host-private policy edit finds the relevant command contracts without searching the larger secret-file suite.
- The split preserves generated output and command reason metadata.

## Failure Signals

- Host-private assertions drift back into project secret-file detection tests.
- A later suite move changes generated policy output or drops executable coverage.

## Result

Unjudged.
