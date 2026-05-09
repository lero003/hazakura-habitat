---
type: nenrin_change
id: agent-context-git-review-first-handoff
date: 2026-05-09
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

# Change: agent-context-git-review-first-handoff

## Changed

- Added an output-contract test proving Git/GitHub mutation guards summarized out of `agent_context.md` remain concrete `Review First` entries in `command_policy.md`.
- Updated status, roadmap, self-use, and changelog notes so the short-context reminder is treated as a handoff to exact policy detail, not as a replacement for it.

## Reason

The short context must stay compact, but Git/GitHub mutation remains command-changing. The useful behavior is a one-line reminder in `agent_context.md` plus exact commands in `command_policy.md` before mutation.

## Expected Behavior

- Agents do not expect every Git/GitHub command to be listed in the short context.
- Agents still inspect `command_policy.md` before workspace, history, branch, or remote Git/GitHub mutation.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later self-use follows the short Git/GitHub reminder into `Review First` instead of treating the summary as vague.
- Future policy output changes keep compact context and exact mutation review detail aligned.

## Failure Signals

- Agents skip `command_policy.md` for Git/GitHub mutation because the short context omits concrete commands.
- Future rendering changes remove concrete Git/GitHub commands from `Review First` while keeping the short reminder.

## Result

Unjudged.
