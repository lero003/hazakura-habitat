---
type: nenrin_change
id: core-markdown-artifact-contract
date: 2026-05-16
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/ReportWriter.swift
  - Tests/HabitatCoreTests/CoreInfrastructureTests.swift
  - docs/agent_contract.md
  - docs/current_status.md
review_after:
  tasks: 3
  days: 7
---

# Change: core-markdown-artifact-contract

## Changed

- Centralized the three core Markdown artifact metadata definitions in
  `ReportWriter`: filename, role, `agentUse`, `readTrigger`, `readOrder`,
  preferred entry section, and line-limit boundary.
- Documented this as a narrow v1-stable candidate while keeping detailed
  `scan_result.json` metadata preview-scoped.

## Reason

`v0.9` hardening should sort stable and preview boundaries without declaring the
whole JSON schema stable. Agents and helper scripts already depend on the three
Markdown artifacts having consistent names, roles, and read triggers; keeping
those strings in one generator-side contract reduces drift risk without changing
the generated output.

## Expected Behavior

- `agent_context.md` remains the first working input.
- `command_policy.md` remains the policy detail to consult before risky or
  mutating commands.
- `environment_report.md` remains diagnostic/audit detail.
- Future metadata edits touch one artifact contract boundary and continue to be
  pinned by `CoreInfrastructureTests`.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Helpers and docs continue to agree on the three core Markdown artifact names,
  roles, read order, and read triggers.
- Future v0.9 work classifies only narrow stable candidates instead of treating
  all `scan_result.json` fields as frozen.

## Failure Signals

- A future report adds or renames a core Markdown artifact without updating the
  central contract and output-contract tests together.
- Scripts start depending on preview-only line counts or section metadata as if
  they were full-schema guarantees.

## Result

Unjudged.
