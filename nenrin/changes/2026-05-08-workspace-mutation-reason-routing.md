---
type: nenrin_change
id: workspace-mutation-reason-routing
date: 2026-05-08
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/PolicyReasonCatalog.swift
  - Sources/HabitatCore/PolicyReasonCatalog+WorkspaceMutation.swift
  - Tests/HabitatCoreTests/PolicyReasonCatalogTests.swift
  - Tests/HabitatCoreTests/WorkspaceMutationPolicyTests.swift
  - CHANGELOG.md
  - docs/current_status.md
  - docs/roadmap.md
  - docs/self_use.md
review_after:
  tasks: 3
  days: 7
---

# Change: workspace-mutation-reason-routing

## Changed

- Routed workspace mutation commands through their catalog family before generic dependency-mutation fallback.
- Added tests proving `rm`, `rm -r`, `rm -rf`, and `xargs rm` keep `user_approval_required` reason metadata.

## Reason

Deletion and bulk workspace mutation commands were already Ask First, but `rm`-style commands could be explained as `dependency_mutation` because the generic mutation-word fallback matched first. That makes generated command-reason metadata less trustworthy for agents reading `command_policy.md` or `scan_result.json`.

## Expected Behavior

- Future workspace-mutation edits preserve a reason family that describes file/workspace risk instead of dependency risk.
- Agents reviewing `rm`-style commands see generic approval/workspace-mutation risk rather than a misleading dependency-change explanation.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later workspace mutation policy edits do not reintroduce dependency-mutation reason metadata for deletion commands.
- `command_policy.md` and `scan_result.json` remain easier to trust for command-decision review.

## Failure Signals

- New workspace mutation commands fall back to unrelated dependency, package, or registry reason codes.
- Agents still need to infer from command text that a reason code is misleading.

## Result

Unjudged.
