---
type: nenrin_observation
id: skill-helper-sandbox-fallback-001
date: 2026-05-09
related_changes:
  - skill-helper-sandbox-fallback
impact_judgment: effective
success_tags:
  - command_shape_refined
  - self_scan_completed
  - global_mutation_avoided
failure_tags: []
---

# Observation: skill-helper-sandbox-fallback-001

## Task

Daily Habitat self-use loop after the `v0.5.0 Developer Preview`.

## Observed Behavior

- Plain `swift build` failed before the self-scan could refresh because SwiftPM tried to write host cache output outside the writable workspace.
- The fallback kept the command decision on SwiftPM verification, used a writable process-local compiler cache plus `--disable-sandbox`, and then completed a fresh `habitat-report`.
- The retry avoided dependency resolution, package installation, global cache deletion, stale release artifacts, and Git shortcuts.

## Success Signals Observed

- A fresh self-scan completed and still selected SwiftPM with `swift test` / `swift build`.
- The behavior is now recorded as `examples/behavior-evaluation/swiftpm-self-use-013.json` with a specific test.
- The fixture keeps raw local paths and raw SwiftPM error text out of stored evidence.

## Failure Signals Observed

- None observed in this slice.

## Impact Judgment

effective

## Next Action

- Keep retry wording in self-use guidance unless repeated preflight failures show generated SwiftPM context should mention the restricted-environment retry shape directly.
