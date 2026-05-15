---
type: nenrin_change
id: skill-helper-unique-temp-output
date: 2026-05-15
status: observing
impact: unknown
related_files:
  - skills/hazakura-habitat/SKILL.md
  - skills/hazakura-habitat/scripts/run_habitat_scan.sh
  - Tests/HabitatCoreTests/ScanExecutionInfrastructureTests.swift
review_after:
  tasks: 3
  days: 7
---

# Change: skill-helper-unique-temp-output

## Changed

- Made the bundled skill helper choose a unique temporary report directory when
  the target repository does not ignore `habitat-report/`.
- Updated the skill's manual temporary-output example to use `mktemp -d` and to
  avoid deleting an older report directory before rescanning.
- Added a helper-level regression test for the unique temporary output path.

## Reason

Cross-project intake needs fresh scans of watched repositories without mutating
their `habitat-report/` directories. A fixed temporary output path makes agents
more likely to pre-clean the directory with deletion commands before scanning,
which is avoidable command friction.

## Expected Behavior

- Agents running the skill against a repository that does not ignore
  `habitat-report/` get a fresh temporary report path by default.
- Fresh cross-project scans do not require `rm -rf` cleanup as a prerequisite.
- Cleanup remains ordinary local housekeeping, not a Habitat command-decision
  step.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Future cross-project intake uses new temporary output paths directly.
- No watched-project report directories are updated just to refresh guidance.
- Agents do not reach for deletion commands before temporary scans.

## Failure Signals

- The helper leaves agents unable to find the generated `agent_context.md`.
- Temporary report paths become hard to inspect or compare during intake.

## Result

Unjudged.
