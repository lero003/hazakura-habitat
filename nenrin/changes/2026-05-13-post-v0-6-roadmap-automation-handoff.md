---
type: nenrin_change
id: post-v0-6-roadmap-automation-handoff
date: 2026-05-13
status: observing
impact: unknown
related_files:
  - README.md
  - CHANGELOG.md
  - docs/current_status.md
  - docs/roadmap.md
  - docs/development_loop.md
review_after:
  tasks: 3
  days: 7
---

# Change: post-v0-6-roadmap-automation-handoff

## Changed

- Clarified that post-`v0.6.0` Habitat work should treat `v0.7` as Distribution Foundations.
- Added binary version, `generatorVersion`, and generated metadata verification to the `v0.7` distribution trust boundary.
- Clarified that a read-only MCP prototype should wait until stdout/file consumption exists and still proves insufficient.
- Kept validation-command purpose clarity as an early bounded `v0.7` slice, not a broad taxonomy release by default.
- Moved deeper validation taxonomy, cross-project observation boundaries, and Nenrin review hygiene into later Observation -> Action work unless fresh command-decision evidence pulls a smaller piece forward.
- Updated automation-facing development-loop guidance so recurring runs do not continue the post-`v0.5` observation loop or broaden into workspace intelligence.

## Reason

External review split on whether `v0.7` should focus on validation taxonomy or distribution trust. The repo already shipped the narrow `swift test` versus release-artifact script correction in `v0.6.0`, while the public preview still has consumption and install-trust gaps. The durable compromise is to keep the release theme on distribution while allowing the minimal validation-purpose split that directly affects first-command guidance.

## Expected Behavior

- Future automation starts from `v0.7` Distribution Foundations, not from the historical post-`v0.5` loop.
- Agents prioritize stdout/file-consumption, checksum-first install guidance, and read-only integration friction before broad scanner taxonomy.
- If validation-purpose work is chosen, agents separate ordinary local validation from release/artifact validation and keep broader setup/lint/smoke/package/CI labels out of scope until repeated evidence justifies them.
- Cross-project and Nenrin signals remain observational and do not choose Habitat's work unless they change a Habitat command decision.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- The next Habitat automation run selects a `v0.7` distribution or minimal validation-purpose slice instead of continuing post-`v0.5` evidence work.
- Release-prep or packaging scripts are not promoted as ordinary first validation commands.
- Cross-project intake and Nenrin records stay bounded to judgment changes.

## Failure Signals

- Automation treats validation taxonomy as permission to add broad command categories without repeated behavior evidence.
- Distribution work turns into automatic installation, command execution, or remote script piping.
- Nenrin records duplicate changelog history instead of preserving a future judgment.

## Result

Unjudged.
