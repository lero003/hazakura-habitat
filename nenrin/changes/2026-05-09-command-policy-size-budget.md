---
type: nenrin_change
id: command-policy-size-budget
date: 2026-05-09
status: observing
impact: unknown
related_files:
  - Tests/HabitatCoreTests/PolicyOutputContractTests.swift
  - CHANGELOG.md
  - docs/current_status.md
  - docs/roadmap.md
  - docs/self_use.md
review_after:
  tasks: 3
  days: 7
---

# Change: command-policy-size-budget

## Changed

- Added a `PolicyOutputContractTests` contract that keeps a representative full `command_policy.md` under the preview readability budget.
- Documented that future command-policy growth should update the budget deliberately instead of silently normalizing longer approval output.

## Reason

The complete command policy is already long enough that agents rely on the index, Review First block, reason codes, and short `agent_context.md` to avoid reading everything. A narrow size-budget contract makes further policy growth visible at test time before it weakens the AI-facing command-decision context.

## Expected Behavior

- Small policy metadata and catalog changes keep passing without generated-output behavior changes.
- Broad ecosystem or command-family growth fails the budget test unless the new size is an explicit product decision.
- Agents continue to treat `command_policy.md` as detailed approval context, not an unbounded environment dashboard.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later policy additions either stay within the budget or update the budget with a clear rationale.
- The size contract catches accidental duplication or verbose generated Markdown before it becomes normal.

## Failure Signals

- The budget becomes busywork and is raised without pruning, grouping, or a command-decision reason.
- Agents still struggle to find relevant approval guidance despite the policy staying within budget.

## Result

Unjudged.
