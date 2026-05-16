---
type: nenrin_change
id: previous-scan-tool-signal-values
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

# Change: previous-scan-tool-signal-values

## Changed

- Added structured `previousValues` and `currentValues` to previous-scan
  `missing_tools` and `tool_verification` changes.
- Kept the short Markdown change summaries unchanged while making
  `scan_result.json` expose affected tool names directly.
- Updated the agent contract and current status wording so the structured
  `changes` boundary includes missing-tool and tool-verification deltas.

## Reason

Missing or unverifiable project tools are command-decision facts. During `v0.9`
hardening, stale-report consumers should not need to parse human summary prose
to decide whether current build, test, or install commands are blocked by
missing-tool or version-check evidence.

## Expected Behavior

- Machine consumers can inspect affected tool names from structured values
  before trusting stale preferred-command or policy guidance.
- Agents still use the current generated Markdown and command policy as the
  authority for whether a tool-backed command is allowed, Ask First, or absent.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Future stale-report checks use structured tool-signal values instead of
  scraping `missing_tools` or `tool_verification` summary sentences.
- Tool-signal values stay scoped to command-changing previous-scan deltas rather
  than becoming a full tool inventory stability promise.

## Failure Signals

- Consumers treat a tool that is no longer relevant as newly available.
- Agents use structured tool names as permission to run commands without
  checking current policy.

## Result

Unjudged.
