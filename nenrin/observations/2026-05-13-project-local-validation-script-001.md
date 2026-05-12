---
type: nenrin_observation
id: project-local-validation-script-001
date: 2026-05-13
related_changes:
  - project-local-validation-script-uncertainty
impact_judgment: partially_effective
success_tags:
  - command_decision_constrained
  - prefer_order_tightened
  - watched_project_kept_read_only
failure_tags: []
---

# Observation: project-local-validation-script-001

## Task

Daily Habitat loop with read-only ai-mobile intake.

## Observed Behavior

- The saved ai-mobile Habitat report was stale after later documentation and module build-file edits.
- A fresh temporary scan still selected the executable Gradle wrapper and also emitted the project-local `./scripts/assemble-debug.sh` validation claim.
- The next command decision changed from raw Gradle validation toward checking whether the documented script is the intended wrapper.
- A follow-up output-contract slice promoted the existing script claim into the short `Prefer` list before raw `./gradlew` commands when the script exists.

## Success Signals Observed

- The watched project stayed read-only.
- The behavior is now recorded as `examples/behavior-evaluation/project-local-validation-script-001.json` with a specific test.
- The short context now makes the documented script harder to miss without adding Android-specific scanning.
- The observation did not expand Habitat into Android environment auditing.

## Failure Signals Observed

- No new Android ecosystem scope was added.

## Impact Judgment

partially_effective

## Next Action

- Watch whether future agents still bypass documented validation wrappers; add a narrower wrapper-command fixture only if that happens.
