---
type: nenrin_change
id: hyphenated-current-doc-freshness
date: 2026-06-21
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/ProjectDetector.swift
  - Tests/HabitatCoreTests/ScanExecutionInfrastructureTests.swift
  - Tests/HabitatCoreTests/InstructionAlignmentPolicyTests.swift
  - Tests/HabitatCoreTests/CrossProjectBehaviorEvaluationTests.swift
  - examples/behavior-evaluation/cross-project-hyphenated-current-docs-001.json
  - docs/current_status.md
  - docs/evaluation.md
  - examples/README.md
review_after:
  tasks: 3
  days: 7
---

# Change: hyphenated-current-doc-freshness

## Changed

- Added `docs/current-work.md` and `docs/current-status.md` to bounded project-guidance detection so they appear in `project.observedFiles` freshness metadata when present.
- Added `docs/current-work.md` and `docs/current-status.md` to sanitized validation-command claim inputs.
- Treated `verification` wording as validation context, matching current queue docs that list focused proof commands under `Verification`.
- Detected selected package-manager script claims such as `npm run build:vite` when the script exists in `package.json`, without promoting arbitrary undocumented scripts.
- Recorded the Hazakura Editor observation as a cross-project behavior fixture.

## Reason

Hazakura Editor now uses hyphenated current docs as the active queue and current-state authority. A fresh cross-project scan selected npm correctly but only surfaced `docs/roadmap.md` freshness drift; it did not include `docs/current-work.md` or `docs/current-status.md`, even though those files decide the next safe editor slice and often list proof commands such as `npm run build:vite`.

## Expected Behavior

- Agents comparing saved reports can see when hyphenated current queue/status docs changed after `Scanned at`.
- Habitat can record sanitized proof-command claims from the active queue without copying raw doc prose into generated artifacts.
- Cross-project intake remains read-only and does not become Tauri-specific planning or report lifecycle automation.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- A future editor or sibling-repo intake treats current queue/status doc changes as stale-report evidence without hand-comparing untracked files.
- Generated context continues to stay short and command-decision focused.

## Failure Signals

- The added guidance files create noisy freshness churn without changing whether agents refresh stale reports.
- Validation-claim extraction from current docs overstates broad release or planning prose as ordinary local validation.

## Result

Unjudged.
