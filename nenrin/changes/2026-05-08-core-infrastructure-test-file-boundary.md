---
type: nenrin_change
id: core-infrastructure-test-file-boundary
date: 2026-05-08
status: observing
impact: unknown
related_files:
  - Tests/HabitatCoreTests/CoreInfrastructureTests.swift
  - docs/current_status.md
  - docs/roadmap.md
  - docs/self_use.md
review_after:
  tasks: 3
  days: 7
---

# Change: core-infrastructure-test-file-boundary

## Changed

- Renamed the remaining `HabitatCoreTests.swift` test file to `CoreInfrastructureTests.swift`.
- Kept the existing `CoreInfrastructureTests` suite body unchanged, preserving generated output, reason codes, scanner behavior, and test coverage.

## Reason

After the scenario-grouped test split, the remaining file name still looked like a module-wide catch-all even though the suite only owned report writing, generated artifact metadata, snapshots, older JSON decoding, previous-scan loading, and diagnostic filtering. Naming the file after the suite reduces the chance that future unrelated policy fixtures drift back into a generic core test file.

## Expected Behavior

- Future report-writer, artifact-metadata, decoding, previous-scan, or diagnostic-filter edits start from `CoreInfrastructureTests.swift`.
- New scanner or command-policy fixtures continue to use their scenario-owned suites instead of reviving a catch-all test file.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- A later core output-contract edit finds the relevant tests without searching for the old generic filename.
- The rename preserves generated output and executable coverage.

## Failure Signals

- Unrelated scanner or policy fixtures accumulate in `CoreInfrastructureTests.swift`.
- A later suite move changes generated policy output or drops executable coverage.

## Result

Unjudged.
