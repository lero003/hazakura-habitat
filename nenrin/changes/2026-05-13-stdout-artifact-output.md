---
type: nenrin_change
id: stdout-artifact-output
date: 2026-05-13
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/ScanArguments.swift
  - Sources/HabitatCore/ReportWriter.swift
  - Sources/habitat-scan/main.swift
  - Tests/HabitatCoreTests/ScanExecutionInfrastructureTests.swift
  - Tests/HabitatCoreTests/CoreInfrastructureTests.swift
  - README.md
  - docs/current_status.md
review_after:
  tasks: 3
  days: 7
---

# Change: stdout-artifact-output

## Changed

- Added `--stdout agent-context` and `--stdout command-policy` for direct generated Markdown consumption.
- Reused the same report rendering path as file output, so stdout output does not fork the artifact contract.
- Allowed `habitat-scan scan --help` as a scan-specific help entrypoint, so agents can discover stdout/file output forms without triggering an argument error.
- Documented when to use stdout versus durable `habitat-report/` files.

## Reason

`v0.7` Distribution Foundations should reduce file-plumbing friction for agents, automation, and local scripts without turning Habitat into an installer, planner, or command-enforcement layer.

## Expected Behavior

- Agents can fetch the short working context without creating or locating `habitat-report/agent_context.md`.
- Scripts can consult the full policy through stdout when they do not need `scan_result.json` or diagnostics.
- File output remains the path for durable report snapshots and machine metadata.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Future automation can replace temporary report-file reads with stdout when only one Markdown artifact is needed.
- The stdout path stays byte-for-byte aligned with the generated report renderer.
- Agents checking scan usage use `scan --help` successfully before choosing `--stdout` or `--output`.

## Failure Signals

- Agents need `scan_result.json` but accidentally use stdout-only output.
- Stdout output diverges from file output or gains status/log noise.

## Result

Unjudged.
