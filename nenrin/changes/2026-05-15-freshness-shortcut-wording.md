---
type: nenrin_change
id: freshness-shortcut-wording
date: 2026-05-15
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/ReportWriter.swift
  - Tests/HabitatCoreTests/RepresentativeExampleTests.swift
  - docs/agent_contract.md
  - docs/evaluation.md
  - examples/swift-package/agent_context.md
review_after:
  tasks: 3
  days: 7
---

# Change: freshness-shortcut-wording

## Changed

- Clarified `agent_context.md` freshness wording so agents compare relevant key
  files with `scan_result.json` `observedFiles` and treat `latestObservedFile`
  as a shortcut only.

## Reason

Fresh ai-mobile intake showed a saved report could keep stale raw Gradle
preferences after README changed, while the short latest-observed-file hint did
not by itself point at that specific changed file.

## Expected Behavior

- Agents checking saved reports do not treat the latest observed file as the
  whole freshness decision.
- Cross-project intake refreshes when any command-changing key file is newer
  than the saved observed-file mtime.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Future external intake catches stale README, instruction, package, or ledger
  changes without adding broad report lifecycle automation.
- Agents still use `latestObservedFilePath` as a quick clue, not as the only
  stale-report check.

## Failure Signals

- Agents continue trusting stale saved reports because the relevant changed file
  was not the saved latest observed file.
- The wording pushes Habitat toward a report watcher, installer, or command
  enforcement role.

## Result

Unjudged.
