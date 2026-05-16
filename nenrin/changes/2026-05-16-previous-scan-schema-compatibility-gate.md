---
type: nenrin_change
id: previous-scan-schema-compatibility-gate
date: 2026-05-16
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/ScanComparator.swift
  - Tests/HabitatCoreTests/ScanComparisonTests.swift
  - docs/agent_contract.md
  - docs/current_status.md
  - docs/roadmap.md
  - CHANGELOG.md
review_after:
  tasks: 3
  days: 7
---

# Change: previous-scan-schema-compatibility-gate

## Changed

- Changed previous-scan comparison so different `schemaVersion` values stop at
  schema and generator compatibility deltas.
- Added a regression test proving lower-level package, lockfile, runtime,
  secret-file, missing-tool, preferred-command, and command-policy deltas are
  not emitted from an incompatible previous schema.
- Clarified the agent contract and current status wording for this bounded
  preview-format uncertainty.

## Reason

`schemaVersion` mismatch means the old JSON shape is preview-format context, not
a fully comparable source of command facts. Emitting detailed command deltas
after that mismatch could make agents treat incompatible metadata as current
environment drift. The safer v0.9 boundary is to preserve the compatibility
signal and prefer the current generated Markdown.

## Expected Behavior

- Agents see schema/generator compatibility drift without also receiving
  lower-confidence command-decision deltas from the old schema.
- Machine consumers can stop at `changes[].category == "schema"` before trying
  to interpret lower-level previous-scan metadata.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Future previous-scan work keeps schema mismatch as bounded uncertainty rather
  than broad comparison failure or overconfident stale-report analysis.
- Current-schema comparisons still surface observed-file, preferred-command,
  and command-policy deltas normally.

## Failure Signals

- Agents ignore the schema compatibility delta and infer environment or policy
  drift from an incompatible previous report.
- The gate is mistaken for a full `scan_result.json` v1 stability promise.

## Result

Unjudged.
