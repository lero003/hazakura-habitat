---
type: nenrin_change
id: previous-scan-version-guidance-values
date: 2026-05-16
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/ScanComparator.swift
  - Tests/HabitatCoreTests/ScanComparisonTests.swift
  - docs/agent_contract.md
  - docs/current_status.md
review_after:
  tasks: 3
  days: 7
---

# Change: previous-scan-version-guidance-values

## Changed

- Added structured `previousValues` and `currentValues` to previous-scan
  `package_manager_version` and `runtime_hints` deltas.
- Kept existing Markdown summary and impact text unchanged while making
  version-guidance drift machine-readable in `scan_result.json`.
- Updated the agent contract and current status wording so the structured
  `changes` boundary includes package-manager-version and runtime-hint
  guidance.

## Reason

Package-manager version and runtime hint changes affect whether agents should
re-check active tools before dependency installs, build, or test commands.
During `v0.9` hardening, stale-report consumers should not have to parse
summary prose to identify the old and current version guidance.

## Expected Behavior

- Machine consumers can inspect version-guidance drift directly from
  `scan_result.json`.
- Agents still use the current generated Markdown and command policy as the
  authority before running dependency, build, or test commands.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Future stale-report consumers use structured version-guidance values instead
  of scraping summary text.
- The value arrays stay scoped to command-changing previous-scan deltas rather
  than becoming a stable promise for the full JSON schema.

## Failure Signals

- Consumers treat matching version guidance as proof that a saved report is
  fresh.
- Agents use old runtime or package-manager version values as permission to run
  dependency commands without checking current policy.

## Result

Unjudged.
