---
type: nenrin_change
id: privileged-outside-deletion-boundaries
date: 2026-05-11
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/PolicyReasonCatalog+Privileged.swift
  - Sources/HabitatCore/PolicyReasonCatalog+OutsideProjectDeletion.swift
  - Sources/HabitatCore/PolicyReasonCatalog+BaselinePolicy.swift
  - Tests/HabitatCoreTests/PolicyReasonCatalogTests.swift
  - docs/current_status.md
  - docs/roadmap.md
  - docs/self_use.md
review_after:
  tasks: 3
  days: 7
---

# Change: privileged-outside-deletion-boundaries

## Changed

- Split the old host-boundary static guard file into separate privileged-command and outside-project deletion catalog files.
- Kept the existing public catalog property names and baseline Forbidden manifest order unchanged.
- Added reason-classification coverage for both new leaf families.

## Reason

`sudo` and destructive deletion outside the selected project are both host-boundary safety rules, but they represent different command-decision risks and reason codes. Separate files make future edits less likely to mix privileged execution with path-scope deletion policy.

## Expected Behavior

- Generated `agent_context.md`, `command_policy.md`, and `scan_result.json` remain unchanged.
- Future edits to `sudo`-style privileged policy or outside-project deletion policy start in the correct leaf file.
- Reason routing keeps `privileged_command` and `outside_project_deletion` distinct.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later baseline Forbidden edits use the narrower files without touching unrelated host-boundary policy.
- Output-contract tests continue to pass without fixture churn.

## Failure Signals

- The extra file split makes the tiny static guards harder to find.
- Future edits reintroduce a mixed host-boundary catch-all file.

## Result

Unjudged.
