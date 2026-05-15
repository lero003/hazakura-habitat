---
type: nenrin_change
id: skill-helper-canonical-output-paths
date: 2026-05-15
status: observing
impact: unknown
related_files:
  - docs/current_status.md
  - skills/hazakura-habitat/scripts/run_habitat_scan.sh
  - Tests/HabitatCoreTests/ScanExecutionInfrastructureTests.swift
review_after:
  tasks: 3
  days: 7
---

# Change: skill-helper-canonical-output-paths

## Changed

- Made the bundled Habitat skill helper print canonical generated report paths
  after a scan creates the output directory.
- Added a helper regression test for output paths that contain redundant
  separators.

## Reason

Cross-project fresh scans used temporary report directories and showed that the
helper could print non-canonical read paths such as paths with doubled
separators. The paths still worked, but this adds needless consumption friction
when agents copy the "Read first" file path.

## Expected Behavior

- Future helper output points agents at stable report paths.
- Temporary cross-project scans stay read-only for watched repositories.
- The helper remains simple advisory plumbing and does not change scan output
  location semantics.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Agents use the helper's printed `agent_context.md` and `command_policy.md`
  paths without manual cleanup.
- Temporary scan output remains outside watched repositories when needed.

## Failure Signals

- Printed paths diverge from where `habitat-scan` actually wrote reports.
- The helper starts adding path lifecycle or cleanup behavior beyond display
  normalization.

## Result

Unjudged.
