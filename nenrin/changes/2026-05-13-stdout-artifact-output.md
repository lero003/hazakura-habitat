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
  - scripts/check_habitat_metadata.sh
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
- Added `--stdout scan-result` for direct machine-readable metadata consumption.
- Added `scripts/check_habitat_metadata.sh` as a small script-consumption helper
  that compares binary `--version` with stdout `generatorVersion` without
  creating or updating `habitat-report/`.
- Tightened the helper contract so local scripts also fail when stdout
  `scan_result.json` is missing core generated Markdown artifact metadata for
  `agent_context.md` or `command_policy.md`.
- Tightened the helper contract again so local scripts require those core
  artifacts to carry the expected role, relative path, Markdown format, read
  order, and agent-use metadata before trusting a binary's consumption path.
- Tightened the helper contract again so local scripts also fail when
  `--stdout agent-context` or `--stdout command-policy` does not return the
  expected generated Markdown artifact.
- Reused the same report rendering path as file output, so stdout output does not fork the artifact contract.
- Allowed `habitat-scan scan --help` as a scan-specific help entrypoint, so agents can discover stdout/file output forms without triggering an argument error.
- Documented when to use stdout versus durable `habitat-report/` files.

## Reason

`v0.7` Distribution Foundations should reduce file-plumbing friction for agents, automation, and local scripts without turning Habitat into an installer, planner, or command-enforcement layer.

## Expected Behavior

- Agents can fetch the short working context without creating or locating `habitat-report/agent_context.md`.
- Scripts can consult `scan_result.json` or the full policy through stdout when they do not need diagnostics or durable report snapshots.
- Scripts can reject a malformed or incomplete generated-Markdown metadata
  contract before trusting generated Markdown paths or roles.
- Scripts can reject subtly incomplete artifact metadata where the name exists
  but the agent-facing role, path, format, or read-order contract is wrong.
- Scripts can reject a broken direct stdout Markdown path before wiring agents
  or automation to a binary.
- File output remains the path for durable report snapshots and environment diagnostics.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Future automation can replace temporary report-file reads with stdout when only one generated artifact is needed.
- The stdout path stays byte-for-byte aligned with the generated report renderer.
- Metadata checks catch missing core artifact entries before downstream scripts
  assume the report is consumable.
- Metadata checks catch wrong core artifact roles, paths, formats, read order,
  or agent-use hints before downstream scripts wire agents to the wrong file.
- Metadata checks catch broken direct stdout Markdown output before downstream
  scripts consume it.
- Agents checking scan usage use `scan --help` successfully before choosing `--stdout` or `--output`.

## Failure Signals

- Agents need `scan_result.json` but accidentally use stdout-only output.
- Stdout output diverges from file output or gains status/log noise.
- A helper accepts scan-result JSON without the core artifact metadata that
  agents and scripts rely on for consumption.
- A helper accepts named artifact entries whose role, path, format, read order,
  or agent-use hints would make downstream consumption ambiguous.
- A helper accepts a binary whose metadata says the Markdown artifacts exist but
  whose direct stdout Markdown output is unavailable or malformed.

## Result

Unjudged.
