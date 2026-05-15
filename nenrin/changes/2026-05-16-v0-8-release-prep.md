---
type: nenrin_change
id: v0-8-release-prep
date: 2026-05-16
status: observing
impact: unknown
related_files:
  - README.md
  - CHANGELOG.md
  - docs/current_status.md
  - docs/roadmap.md
  - Sources/HabitatCore/HabitatMetadata.swift
review_after:
  tasks: 3
  days: 7
---

# Change: v0-8-release-prep

## Changed

- Cut the release-prep docs and version surfaces for v0.8.0 Developer Preview: generatorVersion, README/current status, roadmap first shipped slice, CHANGELOG, helper examples, and representative generator-version examples.

## Reason

External review and local release evidence agreed that post-v0.7 work is a minor preview release, not a v0.7.1 patch: previous-scan comparison, freshness deltas, preferred-command deltas, command-policy transition visibility, generator traceability, helper reliability, and adoption guidance form the first Observation -> Action hardening slice.

## Expected Behavior

- Future agents treat v0.8.0 as a small shipped hardening slice while keeping cross-project observation, MCP, Linux, and deeper validation taxonomy deferred until repeated command-decision evidence justifies them.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Future release-prep runs check version surfaces, CHANGELOG shape, generated
  examples, self-scan generator visibility, and release artifacts before
  publishing a tag.
- Agents describe `v0.8.0` as Observation -> Action hardening rather than as
  completed cross-project observation, MCP, Linux support, or broad taxonomy
  work.

## Failure Signals

- Future agents treat `v0.8.0` as a guarantee that stale context is prevented
  or that agents will choose the correct command.
- Release follow-up reopens `v0.7.0` tags or assets instead of keeping public
  releases immutable.

## Result

Unjudged.
