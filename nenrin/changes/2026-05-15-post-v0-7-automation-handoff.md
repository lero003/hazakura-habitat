---
type: nenrin_change
id: post-v0-7-automation-handoff
date: 2026-05-15
status: observing
impact: unknown
related_files:
  - docs/current_status.md
  - docs/development_loop.md
  - /Users/keisetsu/.codex/automations/hazakura-habitat-1/automation.toml
review_after:
  tasks: 3
  days: 7
---

# Change: post-v0-7-automation-handoff

## Changed

- Reframed recurring Habitat automation after `v0.7.0 Developer Preview` from
  release-prep / Distribution Foundations work to `v0.8` Observation -> Action.
- Kept public tags and GitHub Release assets immutable unless an explicit patch
  release is requested.
- Moved `--format`, thin read-only MCP, Linux feasibility notes, setup-guide
  expansion, and broader validation taxonomy behind observed consumption or
  command-decision evidence.

## Reason

The `v0.7.0` release shipped the stdout/file-consumption, checksum-first release
verification, metadata-check, and minimal validation-purpose boundaries. Leaving
the saved automation prompt on the old `v0.7` work selector would make future
runs chase already-shipped release-prep items or broaden distribution work
without evidence.

## Expected Behavior

- Future Habitat automation starts from `v0.8` observation, not from finishing
  `v0.7` Distribution Foundations.
- The first post-release runs verify whether published artifacts, release
  consumption, freshness, or helper guidance actually affect command decisions.
- Distribution carry-over is implemented only when repeated consumption
  friction justifies it.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- The next automation run treats `v0.7.0` as released and immutable.
- No run starts MCP, `--format`, Linux, or broad validation taxonomy work without
  observed friction.
- Cross-project and Nenrin checks stay observational.

## Failure Signals

- Automation attempts another `v0.7` release-prep slice after the public release.
- Automation treats deferred distribution candidates as required unfinished
  release work.
- Nenrin records duplicate changelog history instead of preserving judgment.

## Result

Unjudged.
