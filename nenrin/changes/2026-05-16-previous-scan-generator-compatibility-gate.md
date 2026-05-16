---
type: nenrin_change
id: previous-scan-generator-compatibility-gate
date: 2026-05-16
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/ScanComparator.swift
  - Tests/HabitatCoreTests/ScanComparisonTests.swift
  - docs/agent_contract.md
  - docs/current_status.md
  - CHANGELOG.md
review_after:
  tasks: 3
  days: 7
---

# Change: previous-scan-generator-compatibility-gate

## Changed

- Changed previous-scan comparison so different `generatorVersion` values stop
  at the generator compatibility delta.
- Added a regression test proving lower-level package, lockfile, runtime,
  secret-file, missing-tool, preferred-command, and command-policy deltas are
  not emitted from a previous scan produced by a different generator.
- Clarified the agent contract and current status wording for this bounded
  generator-change uncertainty.

## Reason

`generatorVersion` mismatch means differences may come from generator behavior,
report shape, or policy rendering rather than repository state. Emitting
lower-level deltas after that mismatch could make agents treat generator drift
as current environment drift. The safer v0.9 boundary is to preserve the
generator signal and prefer the current generated Markdown.

## Expected Behavior

- Agents see generator compatibility drift without also receiving lower-confidence
  command-decision deltas from the old generator.
- Machine consumers can stop at `changes[].category == "generator"` before
  interpreting lower-level previous-scan metadata.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Future previous-scan work keeps generator mismatch as bounded uncertainty
  rather than broad comparison failure or overconfident stale-report analysis.
- Same-generator comparisons still surface observed-file, preferred-command,
  and command-policy deltas normally.

## Failure Signals

- Agents infer package, policy, or preferred-command drift from a previous
  report produced by a different generator.
- The gate is mistaken for a full `scan_result.json` v1 stability promise.

## Result

Unjudged.
