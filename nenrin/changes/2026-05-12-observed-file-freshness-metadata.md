---
type: nenrin_change
id: observed-file-freshness-metadata
date: 2026-05-12
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/Models.swift
  - Sources/HabitatCore/ProjectDetector.swift
  - Sources/HabitatCore/Scanner.swift
  - Tests/HabitatCoreTests/ScanExecutionInfrastructureTests.swift
  - Tests/HabitatCoreTests/RepresentativeExampleTests.swift
  - examples/swift-package/scan_result.json
  - README.md
  - docs/agent_contract.md
  - docs/current_status.md
review_after:
  tasks: 3
  days: 7
---

# Change: observed-file-freshness-metadata

## Changed

- Added `project.observedFiles` metadata with relative paths and modification times for detected project-signal files and CI workflows.
- Added `project.latestObservedFilePath` and `project.latestObservedFileModifiedAt` so agents can quickly compare the newest saved project signal before deciding whether to inspect the full observed-file list.
- Extended observed-file coverage to project guidance documents such as `docs/current_status.md`, `docs/development_automation.md`, `docs/development_loop.md`, `docs/evaluation.md`, `docs/roadmap.md`, `docs/self_use.md`, and `docs/agent-usage.md` when present.
- Documented the field as scan-result metadata for report freshness checks.

## Reason

Cross-project observation repeatedly needed manual timestamp comparison before trusting a saved `habitat-report/agent_context.md`. A small machine-readable file snapshot lets agents compare current repository facts with the saved scan without copying raw report text or reading file contents. The ai-mobile intake then showed that agent-facing docs can change after a saved report even when package/build files are stable, so freshness metadata needs to cover a bounded set of guidance files too.

## Expected Behavior

- Agents can detect stale saved reports from `scan_result.json` metadata before trusting package-manager, validation-command, or CI guidance.
- Cross-project intake can notice current-status, automation, roadmap, and self-use doc updates without reading raw prose into Habitat artifacts.
- Habitat remains advisory and does not add report lifecycle automation.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- A future external intake uses `project.latestObservedFileModifiedAt` first, then `project.observedFiles` only when it needs per-file detail.
- No raw instruction prose, file contents, or private absolute paths appear in the metadata.

## Failure Signals

- Agents treat the metadata as a freshness guarantee instead of a comparison aid.
- The field creates noisy output churn without changing whether agents rescan stale reports.

## Result

Unjudged.
