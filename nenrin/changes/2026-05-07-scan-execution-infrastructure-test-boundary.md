---
type: nenrin_change
id: scan-execution-infrastructure-test-boundary
date: 2026-05-07
status: observing
impact: unknown
related_files:
  - Tests/HabitatCoreTests/ScanExecutionInfrastructureTests.swift
  - Tests/HabitatCoreTests/HabitatCoreTests.swift
  - docs/current_status.md
  - docs/roadmap.md
  - docs/self_use.md
review_after:
  tasks: 3
  days: 7
---

# Change: scan-execution-infrastructure-test-boundary

## Changed

- Moved scan argument parsing, missing-tool command-runner behavior, bundled skill helper binary selection, missing-project safety, and missing-command continuation tests into `ScanExecutionInfrastructureTests.swift`.
- Kept generated output, scanner behavior, reason codes, command ordering, and snapshot contents unchanged.

## Reason

The scan entrypoint and failure-mode guards affect whether agents run the right preflight command before touching a project. Keeping those contracts separate from generated-output assertions should make future CLI or helper edits easier to review without hiding command-decision safety checks in the remaining core suite.

## Expected Behavior

- Future scan argument, helper, missing project, or command-runner failure-mode edits start from `ScanExecutionInfrastructureTests.swift`.
- `CoreInfrastructureTests` stays focused on generated artifact writing, decoding compatibility, snapshots, and report-level contracts.
- The split remains no-output-change.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- A later scan-entrypoint or preflight-safety edit finds the relevant contract without searching generated-output tests.
- The split preserves executable coverage and generated-output behavior.

## Failure Signals

- CLI/helper or missing-project assertions drift back into unrelated report-output tests.
- A later suite move changes generated policy output or drops executable coverage.

## Result

Unjudged.
