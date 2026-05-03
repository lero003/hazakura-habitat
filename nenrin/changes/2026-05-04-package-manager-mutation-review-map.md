---
type: nenrin_change
id: package-manager-mutation-review-map
date: 2026-05-04
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/PolicyReasonCatalog.swift
  - Sources/HabitatCore/Scanner.swift
  - Sources/HabitatCore/ReportWriter.swift
  - Tests/HabitatCoreTests/HabitatCoreTests.swift
  - docs/current_status.md
review_after:
  tasks: 3
  days: 7
---

# Change: package-manager-mutation-review-map

## Changed

- Moved the selected package-manager mutation review command map into `PolicyReasonCatalog`.
- Made scanner Ask First ordering and report short-context prioritization consume the same map.
- Added focused coverage for SwiftPM, Homebrew, and unknown package-manager entries.

## Reason

The fresh v0.3 self-use report kept the next command on SwiftPM validation and put selected workflow mutations, especially `swift package update` and `swift package resolve`, ahead of broad package-manager guards. That behavior depended on matching package-manager mutation lists in both scanner generation and report prioritization, which was a maintainability risk for v0.4 policy hardening.

## Expected Behavior

- Generated `agent_context.md`, `command_policy.md`, and `scan_result.json` remain unchanged for existing fixtures.
- Selected package-manager mutation guards stay visible before broad baseline package-manager commands.
- Future changes to selected workflow mutation emphasis update one catalog map instead of duplicated scanner and renderer switches.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Self-use reports still surface `swift package update` and `swift package resolve` before broad dependency mutation families.
- New package-manager mutation review entries do not require duplicate switch edits.
- Generated-output tests stay stable after policy prioritization cleanup.

## Failure Signals

- The catalog map becomes a broad ecosystem expansion point rather than selected workflow review ordering.
- Commands with `user_approval_required` reasons are incorrectly treated as dependency mutation only because they share the selected review map.
- Short-context Ask First ordering changes without an intentional generated-output update.

## Result

Unjudged.
