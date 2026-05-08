---
type: nenrin_change
id: skill-helper-sandbox-fallback
date: 2026-05-08
status: observing
impact: unknown
related_files:
  - skills/hazakura-habitat/SKILL.md
  - skills/hazakura-habitat/scripts/run_habitat_scan.sh
  - Tests/HabitatCoreTests/ScanExecutionInfrastructureTests.swift
  - CHANGELOG.md
  - docs/current_status.md
  - docs/self_use.md
review_after:
  tasks: 3
  days: 7
---

# Change: skill-helper-sandbox-fallback

## Changed

- Updated the bundled Habitat skill helper to retry source-checkout builds with a writable `CLANG_MODULE_CACHE_PATH` and `--disable-sandbox` when plain SwiftPM build fails.
- Clarified the skill's post-`v0.5` / `v0.6` feedback loop guidance: keep Habitat at `repo fact -> short annotation -> command decision -> observed effect`.
- Added a helper test proving the fallback path can build and run the current checkout binary.

## Reason

Agents should be able to use the skill as the practical preflight entrypoint. If restricted automation sandboxes break plain SwiftPM before project code runs, the helper should preserve the same SwiftPM verification decision rather than falling back to stale binaries or asking for broader environment mutation.

## Expected Behavior

- Future Habitat self-scans from the skill continue to use the current checkout when possible.
- Restricted sandbox build failures do not block useful preflight scans when a local cache and `--disable-sandbox` are enough.
- v0.6-facing work records whether annotations changed later command choices, without turning Habitat into a planner.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later agents can run `skills/hazakura-habitat/scripts/run_habitat_scan.sh .` in restricted sessions without manual fallback.
- Follow-up work cites annotation effects rather than treating scan generation as the end of the loop.

## Failure Signals

- The helper masks real SwiftPM or source-checkout failures that should be reported.
- Agents treat the feedback-loop note as permission to produce broad plans instead of command-decision context.

## Result

Unjudged.
