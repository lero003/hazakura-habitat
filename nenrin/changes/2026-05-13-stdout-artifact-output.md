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
  - scripts/print_habitat_artifact.sh
  - Tests/HabitatCoreTests/ScanExecutionInfrastructureTests.swift
  - Tests/HabitatCoreTests/CoreInfrastructureTests.swift
  - README.md
  - docs/current_status.md
  - docs/roadmap.md
  - skills/hazakura-habitat/SKILL.md
review_after:
  tasks: 3
  days: 7
---

# Change: stdout-artifact-output

## Changed

- Added `--stdout agent-context` and `--stdout command-policy` for direct generated Markdown consumption.
- Added `--stdout environment-report` so diagnostic/audit Markdown can be
  consumed through the same stdout-only path when a durable report directory is
  unnecessary.
- Added `--stdout scan-result` for direct machine-readable metadata consumption.
- Added `scripts/check_habitat_metadata.sh` as a small script-consumption helper
  that compares binary `--version` with stdout `generatorVersion` without
  creating or updating `habitat-report/`.
- Tightened the helper contract so local scripts also fail when stdout
  `scan_result.json` is missing core generated Markdown artifact metadata for
  `agent_context.md` or `command_policy.md`.
- Tightened the helper contract again so local scripts require those core
  artifacts to carry the expected role, relative path, Markdown format, read
  order, read triggers, and agent-use metadata before trusting a binary's
  consumption path.
- Tightened the helper contract again so local scripts also fail when
  `--stdout agent-context` or `--stdout command-policy` does not return the
  expected generated Markdown artifact.
- Tightened the helper contract again so local scripts also require
  `environment_report.md` metadata in `scan_result.json`, while keeping direct
  stdout Markdown checks limited to the AI-facing agent context and command
  policy artifacts.
- Tightened the helper contract again so local scripts also fail when
  `--stdout environment-report` does not return the expected diagnostic
  Markdown artifact.
- Tightened the helper contract again so local scripts also require the
  expected generated artifact `readTrigger` values before trusting stdout/file
  consumption guidance.
- Reused the same report rendering path as file output, so stdout output does not fork the artifact contract.
- Allowed `habitat-scan scan --help` as a scan-specific help entrypoint, so agents can discover stdout/file output forms without triggering an argument error.
- Documented when to use stdout versus durable `habitat-report/` files.
- Rejected combined `--stdout` and `--output` scan flags, so direct artifact
  consumption cannot silently ignore a requested durable report path.
- Accepted generated report filenames such as `agent_context.md` and
  `scan_result.json` as `--stdout` aliases, so scripts can pass artifact
  metadata names back to the CLI without translating them into dash-form tokens.
- Tightened the helper contract again so local scripts verify the same filename
  aliases before trusting metadata-driven artifact consumption.
- Tightened the helper contract again so local scripts reject unexpected
  `schemaVersion` values before trusting `scan_result.json` as the expected
  preview metadata shape.
- Added `scripts/print_habitat_artifact.sh` so local scripts can print one
  verified generated artifact to stdout after checking binary version,
  `generatorVersion`, expected preview `schemaVersion`, and requested artifact
  metadata, while sending verification failures to stderr and leaving
  `habitat-report/` untouched.
- Tightened the print helper contract so it also requires the requested
  Markdown artifact to carry the expected read order, read trigger, and
  agent-use metadata before printing it to stdout.

## Reason

`v0.7` Distribution Foundations should reduce file-plumbing friction for agents, automation, and local scripts without turning Habitat into an installer, planner, or command-enforcement layer.

## Expected Behavior

- Agents can fetch the short working context without creating or locating `habitat-report/agent_context.md`.
- Scripts can consult `scan_result.json`, the full policy, or diagnostics
  through stdout when they do not need durable report snapshots.
- Scripts can reject a malformed or incomplete generated-Markdown metadata
  contract before trusting generated Markdown paths or roles.
- Scripts can reject subtly incomplete artifact metadata where the name exists
  but the agent-facing role, path, format, read-order, or read-trigger contract
  is wrong.
- Scripts can reject a broken direct stdout Markdown path before wiring agents
  or automation to a binary.
- Scripts can reject a binary whose machine-readable artifact list omits the
  diagnostic report metadata or whose direct diagnostic stdout path is
  unavailable.
- Scripts can reject artifact metadata whose read triggers would point agents
  at the wrong generated file or make policy/detail consultation ambiguous.
- File output remains the path for durable report snapshots.
- Agents and scripts choose either a direct stdout artifact or durable report
  files for one scan command; they do not assume both happened.
- Scripts that read generated artifact metadata can request the same artifact by
  report filename through `--stdout`, reducing filename/token conversion
  mistakes.
- The bundled helper rejects binaries where dash-form stdout tokens work but
  filename aliases do not, before downstream scripts depend on metadata-driven
  artifact names.
- The bundled helper rejects scan-result JSON with an unexpected
  `schemaVersion`, so generator-version agreement alone is not treated as a
  complete machine-consumption contract.
- Scripts can pipe a verified single artifact such as `agent_context.md` or
  `command_policy.md` to an agent or automation step without parsing status
  output or creating durable report files.
- The print helper rejects a requested Markdown artifact whose metadata would
  make an agent read the wrong artifact first or treat policy/detail output as
  ordinary working context.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Future automation can replace temporary report-file reads with stdout when only one generated artifact is needed.
- The stdout path stays byte-for-byte aligned with the generated report renderer.
- Metadata checks catch missing core artifact entries before downstream scripts
  assume the report is consumable.
- Metadata checks catch wrong core artifact roles, paths, formats, read order,
  read triggers, or agent-use hints before downstream scripts wire agents to the
  wrong file.
- Metadata checks catch broken direct stdout Markdown output before downstream
  scripts consume it.
- Metadata checks catch an incomplete generated report metadata set, including
  missing `environment_report.md` metadata, before downstream scripts trust the
  binary for durable file output.
- Metadata checks catch broken direct diagnostic stdout output before
  downstream scripts depend on audit/detail consumption.
- Metadata checks catch wrong generated artifact read triggers before
  downstream scripts rely on automated read-order or consultation decisions.
- Agents checking scan usage use `scan --help` successfully before choosing `--stdout` or `--output`.
- Miscombined stdout/file-output commands fail early with a clear argument
  error instead of leaving stale `habitat-report/` files looking current.
- Scripts can round-trip artifact names from metadata to `--stdout` without
  maintaining a separate dash-token map.
- The helper test suite catches regressions in that filename-alias round trip.
- The helper test suite catches unexpected `schemaVersion` values and prints
  the verified schema in successful logs.
- The print helper test suite catches stdout pollution and verifies that
  version mismatches fail before an artifact is printed.

## Failure Signals

- Agents need `scan_result.json` but accidentally use stdout-only output.
- Stdout output diverges from file output or gains status/log noise.
- A helper accepts scan-result JSON without the core artifact metadata that
  agents and scripts rely on for consumption.
- A helper accepts named artifact entries whose role, path, format, read order,
  read triggers, or agent-use hints would make downstream consumption ambiguous.
- A helper accepts a binary whose metadata says the Markdown artifacts exist but
  whose direct stdout Markdown output is unavailable or malformed.
- A helper accepts a binary whose file-output metadata omits the diagnostic
  report artifact even though scripts may later depend on durable report files.
- A helper accepts a binary whose diagnostic stdout path is missing or malformed.
- A helper accepts artifact metadata with wrong read triggers, leaving agents or
  scripts unsure when to read policy or diagnostics.
- Scripts pass both `--stdout` and `--output`, then trust an old report
  directory because the stdout-only scan did not refresh it.
- Scripts derive `agent_context.md` from metadata, pass it to `--stdout`, and
  fail even though the requested artifact exists.
- A helper accepts a future or malformed schema because `generatorVersion`
  still matches the binary.
- A print helper writes status logs to stdout, causing downstream agents or
  scripts to receive a mixed artifact.
- A print helper prints an artifact before checking binary, generator, schema,
  or requested-artifact metadata.
- A print helper accepts a requested Markdown artifact with the wrong read
  order, read trigger, or agent-use hint and pipes misleading context to an
  agent.

## Result

Unjudged.
