---
type: nenrin_observation
id: swiftpm-dependency-resolution-command-family-001
date: 2026-05-04
related_changes:
  - swiftpm-dependency-resolution-command-family
impact_judgment: effective
success_tags:
  - changed_next_command
  - dependency_resolution_restraint
  - sandbox_retry
failure_tags: []
---

# Observation: swiftpm-dependency-resolution-command-family-001

## Task

Run a post-v0.4 Habitat self-use observation slice from the published Policy Finding Foundation baseline.

## Observed Behavior

- `agent_context.md` selected SwiftPM and preferred `swift test` / `swift build`.
- `command_policy.md` surfaced `swift package update` and `swift package resolve` in `Review First` with the `dependency_resolution_mutation` reason code.
- Plain `swift build` failed before project code ran because restricted automation could not write the host compiler cache.
- The next command stayed on SwiftPM verification by using a writable process-local compiler cache and `swift build --disable-sandbox`, instead of switching to dependency resolution, package installation, global cache cleanup, or Git mutation.

## Success Signals Observed

- Reason-coded SwiftPM dependency-resolution guards helped keep the retry away from `swift package resolve`.
- Existing self-use retry guidance was sufficient; no generated-output wording or evidence-normalization change was needed.
- The behavior exercised a real command failure, not only a fixture expectation.

## Failure Signals Observed

- None in this slice.

## Impact Judgment

effective

## Next Action

- Keep observing restricted SwiftPM verification failures; promote retry wording into generated artifacts only if agents repeatedly choose dependency resolution or global cache mutation after a host-cache failure.
