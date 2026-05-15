---
type: nenrin_observation
id: gradle-wrapper-script-preference-001
date: 2026-05-15
related_changes:
  - gradle-wrapper-script-preference
impact_judgment: effective
success_tags:
  - preferred-command-replacement
failure_tags: []
---

# Observation: gradle-wrapper-script-preference-001

## Task

Daily post-v0.7 Habitat intake checked the current ai-mobile Habitat report
read-only, then refreshed it into temporary output because README and roadmap
files changed after the saved scan.

## Observed Behavior

- The saved report was stale and still showed raw Gradle validation beside the
  project-local script.
- The fresh scan kept Gradle wrapper detection as the project fact, but the
  ordinary preferred command list contained only `./scripts/assemble-debug.sh`.
- The connected-device script remained device-verification context, not
  ordinary local validation.
- The watched project was not edited and no raw report output was copied into
  Habitat or Nenrin.

## Success Signals Observed

- The known Gradle-wrapper script case now moves agents toward the documented
  wrapper before raw `./gradlew` validation.
- The change did not expand into Android environment auditing or broader
  validation taxonomy.

## Failure Signals Observed

- None observed in this slice.

## Impact Judgment

effective

## Next Action

- Keep observing whether agents actually run the wrapper first; do not add
  broader Gradle task taxonomy from this single success.
