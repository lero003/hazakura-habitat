---
type: nenrin_change
id: habitat-nenrin-self-use
date: 2026-05-03
status: observing
impact: unknown
related_files:
  - docs/development_loop.md
  - docs/self_use.md
  - docs/current_status.md
  - CHANGELOG.md
review_after:
  tasks: 3
  days: 7
---

# Change: habitat-nenrin-self-use

## Changed

- Added a project-local `nenrin/` ledger for Habitat.
- Connected Habitat's self-use loop to Nenrin change and observation records.
- Added guidance that agent-facing docs, skills, roadmap, release, and automation changes should create or update Nenrin records.

## Reason

Habitat already relies on self-use evidence, but its agent-facing workflow improvements need an explicit keep/remove/move review loop. Without a ledger, improvements to docs, skills, handoffs, and automation guidance can be added permanently without later evidence that they changed agent behavior.

## Expected Behavior

- Agents inspect `nenrin/index.md` before substantial Habitat self-use or automation work.
- Agents create or update Nenrin change records when Habitat docs, skills, handoffs, roadmap, release checklists, QA gates, or automation guidance change.
- Agents create observation records after related Habitat work when an active Nenrin change affected the task.
- Recurring automation reports stale observing changes, overdue reviews, recurring failures, and cleanup candidates instead of adding more permanent guidance by default.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- A future Habitat automation slice creates or updates a relevant Nenrin observation without being explicitly reminded.
- `nenrin metrics` separates active change state from observation judgments.
- `nenrin debt` surfaces at least one useful keep/remove/merge/narrow/move decision during Habitat self-use.
- Habitat docs become easier to prune because improvement records explain why a rule exists.

## Failure Signals

- Habitat docs or skills keep changing without corresponding Nenrin records.
- Nenrin records are created but never observed or reviewed.
- Automation treats Nenrin as a generic checklist and adds more rules instead of suggesting removal, narrowing, or movement.
- `nenrin/` becomes stale compared with current Habitat self-use guidance.

## Result

Unjudged.
