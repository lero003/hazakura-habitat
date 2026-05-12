---
type: nenrin_change
id: agent-context-freshness-note
date: 2026-05-12
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/ReportWriter.swift
  - Tests/HabitatCoreTests/CoreInfrastructureTests.swift
  - Tests/HabitatCoreTests/RepresentativeExampleTests.swift
  - examples/swift-package/agent_context.md
  - examples/swift-package/scan_result.json
  - docs/current_status.md
  - docs/evaluation.md
review_after:
  tasks: 3
  days: 7
---

# Change: agent-context-freshness-note

## Changed

- Added a short `agent_context.md` Notes reminder to regenerate reports when key project files changed after `Scanned at`.
- Pointed agents to `scan_result.json` observed file mtimes for freshness comparison.
- Added the latest observed project file and timestamp to the short context, so stale-report intake can often decide whether to refresh without opening JSON first.

## Reason

Cross-project intake found an existing ai-mobile report whose command guidance was useful, but whose README had changed after the scan timestamp. The next command should be a freshness check or temporary rescan, not blind trust in saved Markdown.

## Expected Behavior

- Agents compare saved report timestamps and observed file metadata before relying on package-manager or validation guidance.
- Stale-report handling stays advisory and report-local instead of becoming lifecycle automation.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Future cross-project intakes use the generated note, latest observed-file line, and `scan_result.json` mtimes to decide whether to rescan.
- Agents do not copy raw report output or edit watched projects when handling stale reports.

## Failure Signals

- The extra Notes line is ignored and agents continue trusting stale `agent_context.md` blindly.
- The reminder adds noise without changing rescan decisions.

## Result

Unjudged.
