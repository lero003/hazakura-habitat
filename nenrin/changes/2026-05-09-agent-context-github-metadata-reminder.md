---
type: nenrin_change
id: agent-context-github-metadata-reminder
date: 2026-05-09
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/ReportWriter.swift
  - Tests/HabitatCoreTests/AgentContextOutputContractTests.swift
  - Tests/HabitatCoreTests/CoreInfrastructureTests.swift
  - Tests/HabitatCoreTests/RepresentativeExampleTests.swift
  - examples/swift-package/agent_context.md
  - examples/swift-package/scan_result.json
  - docs/agent_contract.md
  - docs/current_status.md
  - docs/self_use.md
  - docs/evaluation.md
review_after:
  tasks: 3
  days: 7
---

# Change: agent-context-github-metadata-reminder

## Changed

- Clarified the short agent_context Git/GitHub reminder so hidden gh remote metadata actions, including secret and variable reads, are covered by the same command_policy.md review handoff as local Git mutations.
- Updated command_policy.md artifact readTrigger metadata to include risky remote actions, keeping machine-readable reading hints aligned with the short-context wording.

## Reason

Self-scan policy already marks gh secret and variable commands as Ask First remote repository actions, but the short-context summary sounded mutation-only and could let an agent treat read-like remote metadata commands as safe.

## Expected Behavior

- Agents open command_policy.md before GitHub remote metadata actions, not only before local Git workspace or remote mutations.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later self-use opens command_policy.md before gh secret, variable, release, workflow, or API actions even when they look read-like.
- Agents do not treat the shorter Git/GitHub summary as limited to mutating git commands.

## Failure Signals

- Agents skip policy review for GitHub remote metadata reads because the wording is still too broad or buried.
- The expanded readTrigger creates consumer churn without improving command decisions.

## Result

Unjudged.
