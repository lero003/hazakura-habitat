---
type: nenrin_change
id: validation-claim-freshness-metadata
date: 2026-05-13
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/ProjectDetector.swift
  - Tests/HabitatCoreTests/ScanExecutionInfrastructureTests.swift
  - docs/current_status.md
review_after:
  tasks: 3
  days: 7
---

# Change: validation-claim-freshness-metadata

## Changed

- Added `docs/development_environment.md` to observed project files.
- Kept the observed-file contract aligned with the allowlisted validation-command claim inputs.
- Documented that saved reports can become stale when bounded development guidance changes.

## Reason

Habitat reads `docs/development_environment.md` for documented validation-command claims, but the file was not part of freshness metadata. A saved report could therefore keep old command guidance without showing that the source file had changed after `Scanned at`.

## Expected Behavior

- Agents comparing saved reports against visible repository facts can treat changes to `docs/development_environment.md` as stale-report evidence.
- Future validation-command claim inputs should be kept in the same freshness boundary.
- Cross-project intake remains bounded to report freshness and command-decision inputs, not raw report copying.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later automation notices stale validation guidance from observed-file mtimes instead of trusting old report prose.
- Instruction-alignment work keeps claim-source and freshness-source lists synchronized.

## Failure Signals

- Another validation-command source is added without freshness metadata.
- Agents continue to trust saved validation guidance after the source guidance file changes.

## Result

Unjudged.
