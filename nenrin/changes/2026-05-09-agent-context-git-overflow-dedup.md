---
type: nenrin_change
id: agent-context-git-overflow-dedup
date: 2026-05-09
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/ReportWriter.swift
  - Tests/HabitatCoreTests/AgentContextOutputContractTests.swift
  - examples/python-uv-missing-tool/agent_context.md
  - examples/cargo-version-check-failure/agent_context.md
  - docs/agent_contract.md
  - CHANGELOG.md
  - docs/current_status.md
  - docs/roadmap.md
  - docs/self_use.md
review_after:
  tasks: 3
  days: 7
---

# Change: agent-context-git-overflow-dedup

## Changed

- Changed `agent_context.md` Ask First overflow rendering so Git/GitHub guards already covered by the dedicated mutation reminder are excluded from the additional hidden-command count and suffix.
- Updated representative examples and output-contract tests to keep the short context from double-counting summarized Git/GitHub policy entries.

## Reason

The self-scan already gives Git/GitHub mutation a dedicated short-context reminder. Counting those same hidden commands again in the overflow line makes the policy look larger and less precise than the next command decision requires.

## Expected Behavior

- Agents still see the Git/GitHub mutation reminder before commit, push, branch, workspace, or remote actions.
- The additional Ask First count describes only the remaining hidden command families that were not already summarized.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later self-use treats the overflow count as a precise pointer to remaining policy detail rather than a duplicate of the Git/GitHub reminder.
- Agents still inspect `command_policy.md` before Git/GitHub mutation.

## Failure Signals

- Agents misread the smaller overflow count as permission to skip Git/GitHub policy review.
- Future output changes need the Git/GitHub reminder and overflow count merged into a single clearer line.

## Result

Unjudged.
