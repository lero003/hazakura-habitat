---
type: nenrin_change
id: baseline-command-policy-test-boundary
date: 2026-05-07
status: observing
impact: unknown
related_files:
  - Tests/HabitatCoreTests/BaselineCommandPolicyTests.swift
  - Tests/HabitatCoreTests/PackageAndCommandPolicyTests.swift
  - docs/current_status.md
  - docs/roadmap.md
  - docs/self_use.md
review_after:
  tasks: 3
  days: 7
---

# Change: baseline-command-policy-test-boundary

## Changed

- Moved lockfile/version-manager mutation, remote-script execution, language global package mutation, and GitHub CLI mutation scenarios into `BaselineCommandPolicyTests.swift`.
- Kept generated output, reason codes, and scanner behavior unchanged.

## Reason

`PackageAndCommandPolicyTests.swift` still mixed broad baseline command-safety contracts with JavaScript metadata/version scenarios. A baseline suite gives future command-policy edits a smaller starting point without changing the policy catalog or scanner behavior.

## Expected Behavior

- Future broad command-safety edits start from `BaselineCommandPolicyTests.swift`.
- `PackageAndCommandPolicyTests.swift` can continue shrinking around JavaScript metadata/version contracts.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- A later baseline policy edit finds lockfile, remote-script, global mutation, or GitHub CLI assertions quickly.
- Test moves continue to preserve output behavior and command reason codes.

## Failure Signals

- Broad baseline assertions are duplicated back into the general package-policy suite.
- A future split drops executable coverage or changes generated policy output unintentionally.

## Result

Unjudged.
