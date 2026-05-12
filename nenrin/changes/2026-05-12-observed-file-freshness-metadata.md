---
type: nenrin_change
id: observed-file-freshness-metadata
date: 2026-05-12
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/Models.swift
  - Sources/HabitatCore/Scanner.swift
  - Tests/HabitatCoreTests/ScanExecutionInfrastructureTests.swift
  - docs/agent_contract.md
  - docs/current_status.md
review_after:
  tasks: 3
  days: 7
---

# Change: observed-file-freshness-metadata

## Changed

- Added `project.observedFiles` metadata with relative paths and modification times for detected project-signal files and CI workflows.
- Documented the field as scan-result metadata for report freshness checks.

## Reason

Cross-project observation repeatedly needed manual timestamp comparison before trusting a saved `habitat-report/agent_context.md`. A small machine-readable file snapshot lets agents compare current repository facts with the saved scan without copying raw report text or reading file contents.

## Expected Behavior

- Agents can detect stale saved reports from `scan_result.json` metadata before trusting package-manager, validation-command, or CI guidance.
- Habitat remains advisory and does not add report lifecycle automation.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- A future external intake uses `project.observedFiles` to decide whether to rescan instead of hand-comparing mtimes.
- No raw instruction prose, file contents, or private absolute paths appear in the metadata.

## Failure Signals

- Agents treat the metadata as a freshness guarantee instead of a comparison aid.
- The field creates noisy output churn without changing whether agents rescan stale reports.

## Result

Unjudged.
