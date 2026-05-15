---
type: nenrin_change
id: agent-context-generator-note
date: 2026-05-16
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/ReportWriter.swift
  - Tests/HabitatCoreTests/CoreInfrastructureTests.swift
  - docs/agent_contract.md
  - docs/current_status.md
  - examples/swift-package/agent_context.md
  - examples/node-pnpm-conflict/agent_context.md
  - examples/python-uv-missing-tool/agent_context.md
  - examples/cargo-version-check-failure/agent_context.md
  - examples/secret-bearing-files/agent_context.md
review_after:
  tasks: 3
  days: 7
---

# Change: agent-context-generator-note

## Changed

- Added the Habitat generator version to `agent_context.md` `Notes`.
- Updated the agent contract, representative examples, and output-contract
  snapshot.

## Reason

Cross-project intake found a saved ai-mobile report whose repository facts were
close enough to look usable, but whose short-context wording came from an older
generator behavior. `scan_result.json` already carried the generator version,
but Markdown-only readers had to open the machine artifact before noticing the
report-shape source.

## Expected Behavior

- Agents can distinguish stale project facts from older generator output before
  trusting saved command guidance.
- Markdown-only report consumers can decide to refresh or compare with
  `--previous-scan` without first parsing JSON.
- The note stays informational and does not become automatic update or
  lifecycle management.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Future stale-report intake checks mention both scan time and generator version
  when deciding whether to refresh.
- Agents avoid treating old saved Markdown wording as current Habitat behavior.

## Failure Signals

- Agents treat generator version as a compatibility guarantee beyond `v0.x`.
- The note encourages release/tag or GitHub asset mutation instead of fresh
  local scans.

## Result

Unjudged.
