---
type: nenrin_change
id: workspace-mutation-policy-test-boundary
date: 2026-05-07
status: observing
impact: unknown
related_files:
  - Tests/HabitatCoreTests/WorkspaceMutationPolicyTests.swift
  - Tests/HabitatCoreTests/PackageAndCommandPolicyTests.swift
  - docs/current_status.md
  - docs/roadmap.md
  - docs/self_use.md
review_after:
  tasks: 3
  days: 7
---

# Change: workspace-mutation-policy-test-boundary

## Changed

- Split Git/workspace mutation, permission/ownership, bulk rewrite/delete, copy/move/sync/archive, and project-outside deletion policy tests out of `PackageAndCommandPolicyTests.swift` into `WorkspaceMutationPolicyTests.swift`.
- Kept scanner behavior, generated Markdown, `scan_result.json`, command ordering, and reason-code behavior unchanged.

## Reason

Workspace mutation safety is one of Habitat's most important command-decision boundaries, but those scenarios were buried inside the general package-policy suite. A focused suite should make future destructive-command policy changes easier to audit without mixing them with package-manager scanner fixtures.

## Expected Behavior

- Future Git/workspace mutation policy edits start from `WorkspaceMutationPolicyTests.swift`.
- Package-manager scanner work does not need to read destructive workspace-command scenarios first.
- Agents keep treating this as a no-output-change test-ownership slice unless policy wording or generated output changes.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- A later destructive-command or Git mutation change uses the focused suite for verification.
- `PackageAndCommandPolicyTests.swift` remains focused on package/runtime scanner scenarios.

## Failure Signals

- Workspace mutation scenarios drift back into the package-policy suite.
- Test ownership becomes unclear enough that destructive-command safety regressions are missed.

## Result

Unjudged.
