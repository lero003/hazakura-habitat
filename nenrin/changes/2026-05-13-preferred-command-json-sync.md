---
type: nenrin_change
id: preferred-command-json-sync
date: 2026-05-13
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/ReportWriter.swift
  - Sources/HabitatCore/Models.swift
  - Tests/HabitatCoreTests/InstructionAlignmentPolicyTests.swift
  - docs/agent_contract.md
  - docs/current_status.md
  - docs/evaluation.md
review_after:
  tasks: 3
  days: 7
---

# Change: preferred-command-json-sync

## Changed

- Synced generated `scan_result.json` `policy.preferredCommands` with the project-local validation script promotion already rendered in `agent_context.md` and `command_policy.md`.
- Added a regression test that keeps executable project-local validation scripts ahead of raw Gradle commands in written JSON, while missing scripts stay out of preferred commands.

## Reason

Fresh ai-mobile intake showed Markdown consumers would prefer `./scripts/assemble-debug.sh`, but machine consumers reading `scan_result.json` still saw raw `./gradlew` commands first.

## Expected Behavior

- Agents and tools that read JSON make the same command decision as agents reading Markdown.
- Missing or non-executable project-local validation scripts remain evidence only and do not become preferred commands.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Future project-local wrapper scans keep `policy.preferredCommands`, `agent_context.md`, and `command_policy.md` aligned.
- Machine consumers do not bypass documented validation wrappers because JSON differs from Markdown.

## Failure Signals

- A report promotes a script in Markdown but not in JSON.
- Missing scripts reappear in `policy.preferredCommands`.

## Result

Unjudged.
