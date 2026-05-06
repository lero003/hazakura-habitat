---
type: nenrin_change
id: workspace-mutation-command-family
date: 2026-05-06
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/PolicyReasonCatalog+WorkspaceMutation.swift
  - Sources/HabitatCore/Scanner.swift
  - Tests/HabitatCoreTests/PackageAndCommandPolicyTests.swift
  - docs/current_status.md
review_after:
  tasks: 3
  days: 7
---

# Change: workspace-mutation-command-family

## Changed

- Centralized workspace mutation Ask First commands in `PolicyReasonCatalog+WorkspaceMutation.swift`.
- Kept permission, inline rewrite, copy/move/sync/archive, extraction, truncation, and delete command ordering unchanged.
- Added catalog classification coverage so these commands keep existing approval behavior, including the legacy `dependency_mutation` fallback for `rm` shapes.

## Reason

The post-v0.4 self-scan still surfaces Git/GitHub and workspace mutation guards as important command-decision context. These non-Git workspace commands were still inline in `Scanner`, making future policy edits easier to duplicate or reorder accidentally.

## Expected Behavior

- Generated command lists, reason codes, and ordering remain unchanged for existing fixtures.
- Agents still ask before workspace mutation commands such as `chmod`, `sed -i`, `cp`, `mv`, `tar -xf`, `unzip`, and `rm -rf`.
- Future workspace-mutation policy edits update one catalog-owned family instead of reintroducing inline command lists in `Scanner`.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Future workspace mutation additions reuse `PolicyReasonCatalog+WorkspaceMutation.swift`.
- Generated policy counts stay stable unless a behavior-driven workspace command addition intentionally changes them.
- Scanner remains focused on assembling policy from catalog-owned families.

## Failure Signals

- Workspace mutation commands lose Ask First coverage.
- Workspace mutation commands accidentally gain or lose reason codes outside the existing fallback behavior.
- Permission, rewrite, copy/move/sync/archive, or delete guards are duplicated outside the catalog boundary.

## Result

Unjudged.
