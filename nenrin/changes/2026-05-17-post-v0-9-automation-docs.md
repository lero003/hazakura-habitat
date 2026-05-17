---
type: nenrin_change
id: post-v0-9-automation-docs
date: 2026-05-17
status: observing
impact: unknown
related_files:
  - docs/development_loop.md
  - docs/current_status.md
  - docs/self_use.md
  - CHANGELOG.md
review_after:
  tasks: 3
  days: 7
---

# Change: post-v0-9-automation-docs

## Changed

- Clarified that post-`v0.9.0` recurring automation should treat the release as
  complete and start from narrow `v1.0` readiness gates.
- Made repo docs the authority when saved automation prompt wording still sounds
  like generic `v0.9` hardening.
- Kept prompt/config sync out of normal repo runs unless the user explicitly
  asks for it.
- Synced the historical self-scan snapshot guidance so it points post-`v0.9.0`
  runs to `v1.0` readiness, docs-only stale-guidance correction, or verified
  no-op instead of the old active `v0.9` lane.

## Reason

The roadmap is stable enough after `v0.9.0`, but the saved automation prompt can
lag behind the repository phase. Without a small handoff correction, recurring
runs may reopen release prep or keep selecting generic `v0.9` boundary work
instead of a concrete `v1.0` readiness gap or verified no-op.

## Expected Behavior

- Future automation reads `docs/development_loop.md` and
  `docs/current_status.md` as the current phase authority; `docs/self_use.md`
  must not pull the run back to the old active `v0.9` lane.
- A stale saved prompt is reported as drift instead of driving the work.
- Docs-only automation changes are reserved for wrong-phase, release-reopen,
  stability-overstatement, or readiness-gate drift.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- The next recurring Habitat run does not repeat `v0.9.0` release prep.
- The run chooses one concrete `v1.0` readiness question, a justified
  docs-only stale-guidance correction, or a verified no-op.

## Failure Signals

- Automation edits saved prompt/config from a normal repo run without explicit
  user request.
- Automation treats post-v1 exploration, MCP, GUI, Linux support, command
  enforcement, or whole-project intelligence as the default next lane.

## Result

Unjudged.
