---
type: nenrin_change
id: agent-context-non-git-overflow-label
date: 2026-05-11
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/ReportWriter.swift
  - Tests/HabitatCoreTests/AgentContextOutputContractTests.swift
  - examples/cargo-version-check-failure/agent_context.md
  - examples/python-uv-missing-tool/agent_context.md
review_after:
  tasks: 3
  days: 7
---

# Change: agent-context-non-git-overflow-label

## Changed

- Clarified the agent_context.md overflow line so counts after the Git/GitHub reminder are labeled as non-Git/GitHub Ask First items.

## Reason

Self-use showed the short context can summarize Git/GitHub guards separately, making the remaining overflow count look inconsistent with command_policy.md unless the scope is named.

## Expected Behavior

- Agents should understand that the Git/GitHub reminder is a compact summary and the following overflow count covers the remaining non-Git/GitHub policy entries.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- TBD

## Failure Signals

- TBD

## Result

Unjudged.
