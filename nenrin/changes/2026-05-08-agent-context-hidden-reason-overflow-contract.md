---
type: nenrin_change
id: agent-context-hidden-reason-overflow-contract
date: 2026-05-08
status: observing
impact: unknown
related_files:
  - Tests/HabitatCoreTests/AgentContextOutputContractTests.swift
  - CHANGELOG.md
  - docs/current_status.md
  - docs/roadmap.md
  - docs/self_use.md
review_after:
  tasks: 3
  days: 7
---

# Change: agent-context-hidden-reason-overflow-contract

## Changed

- Added an `AgentContextOutputContractTests` regression that keeps hidden Ask First overflow summaries bounded to three structured reason codes plus `more`.
- Synced status, roadmap, self-use, and changelog wording so the short-context output contract reflects this specific compactness guard.

## Reason

Self-use now regularly produces long `command_policy.md` output with many Ask First reason families. The short `agent_context.md` should expose enough hidden-risk shape to guide the next command without becoming a second full policy listing.

## Expected Behavior

- Future overflow rendering keeps the short context concise even when hidden Ask First commands span many reason families.
- Agents see the first structured reason-code families and know to open `command_policy.md` for the rest instead of over-reading the short context.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later reason-code or Ask First growth does not bloat `agent_context.md`.
- The overflow line remains useful for deciding whether to inspect `command_policy.md`.

## Failure Signals

- Agents still miss important hidden risks because the summary is too compressed.
- A future renderer change needs a different compact grouping strategy.

## Result

Unjudged.
