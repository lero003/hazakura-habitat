---
type: nenrin_change
id: roadmap-feedback-during-work
date: 2026-05-07
status: observing
impact: unknown
related_files:
  - docs/roadmap.md
  - docs/development_loop.md
review_after:
  tasks: 3
  days: 7
---

# Change: roadmap-feedback-during-work

## Changed

- Clarified that implementation and self-use slices may update the roadmap when observed work reveals a stale priority, over-broad phase, or missing decision boundary.
- Added the rule to keep those roadmap corrections narrow and tied to observed repository facts, behavior, or verification results.
- Made the development loop treat small roadmap/status updates as part of closing an agent-facing slice, not as a separate planning project.

## Reason

The user explicitly asked future agents not to leave useful roadmap corrections in chat when a task shows that the plan should change. The existing docs already allowed later phases to be re-ranked from observed behavior, but they did not state the operational rule for updating roadmap docs during ordinary slices.

## Expected Behavior

- Agents update `docs/roadmap.md` or `docs/current_status.md` when a concrete slice changes the next useful work.
- Agents avoid broad roadmap rewrites when the evidence only supports a small correction.
- Future self-use reports distinguish implementation facts from later planning decisions.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- A later task includes a small roadmap/status correction when implementation evidence changes the work order.
- A later task explicitly leaves the roadmap alone when the evidence does not change the next command or phase boundary.
- Roadmap updates stay tied to observed behavior instead of becoming speculative architecture.

## Failure Signals

- Useful roadmap corrections remain only in chat.
- Agents rewrite phase plans broadly after a narrow implementation observation.
- Nenrin records turn into routine changelog entries instead of behavior-level observations.

## Result

Unjudged.
