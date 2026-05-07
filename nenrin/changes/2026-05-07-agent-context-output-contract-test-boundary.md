---
type: nenrin_change
id: agent-context-output-contract-test-boundary
date: 2026-05-07
status: observing
impact: unknown
related_files:
  - Tests/HabitatCoreTests/AgentContextOutputContractTests.swift
  - Tests/HabitatCoreTests/HabitatCoreTests.swift
  - docs/current_status.md
  - docs/roadmap.md
  - docs/self_use.md
review_after:
  tasks: 3
  days: 7
---

# Change: agent-context-output-contract-test-boundary

## Changed

- Moved short `agent_context.md` overflow, prioritization, hidden Git guard summary, and line-budget contracts into `AgentContextOutputContractTests.swift`.
- Kept generated output, scanner behavior, reason codes, command ordering, and snapshot contents unchanged.

## Reason

The short agent context is Habitat's primary command-decision artifact. Keeping its truncation and prioritization contracts in a dedicated suite should make future output-shape changes easier to review without growing core infrastructure tests.

## Expected Behavior

- Future `agent_context.md` overflow, ordering, summary, or line-budget edits start from `AgentContextOutputContractTests.swift`.
- `CoreInfrastructureTests` stays focused on parser, command-runner, report-writer, decoding, and missing-project guards.
- The split remains no-output-change.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- A later short-context output edit finds the relevant contract without searching the core infrastructure suite.
- The split preserves executable coverage and generated-output behavior.

## Failure Signals

- Short-context overflow assertions drift back into unrelated core infrastructure tests.
- A later suite move changes generated policy output or drops executable coverage.

## Result

Unjudged.
