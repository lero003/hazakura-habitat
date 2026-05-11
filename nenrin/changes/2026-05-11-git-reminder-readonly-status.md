---
type: nenrin_change
id: git-reminder-readonly-status
date: 2026-05-11
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/ReportWriter.swift
  - Tests/HabitatCoreTests/AgentContextOutputContractTests.swift
  - examples/behavior-evaluation/swiftpm-self-use-019.json
  - docs/agent_contract.md
  - docs/evaluation.md
  - docs/current_status.md
  - docs/self_use.md
review_after:
  tasks: 3
  days: 7
---

# Change: git-reminder-readonly-status

## Changed

- Narrowed the short `agent_context.md` Git/GitHub reminder so it names mutating workspace/history/branch/remote commands and remote metadata reads/writes.
- Kept ordinary read-only local `git status --short` out of the implied approval boundary.
- Added behavior evidence for the distinction between local status checks and Git/GitHub mutation or remote metadata review.

## Reason

The daily self-use loop begins with read-only `git status --short --branch`, and pre-commit guidance can also ask agents to run `git status --short` after hooks. The previous short reminder mentioned broad "metadata actions", which could make agents over-ask before local read-only status checks even though concrete policy entries target mutation and remote metadata risk.

## Expected Behavior

- Agents can use local read-only Git status for workspace awareness without treating it as Ask First.
- Agents still consult `command_policy.md` before staging, committing, pushing, destructive Git commands, or GitHub secret/variable metadata commands.
- Future wording changes preserve the distinction between local read-only inspection and remote or mutating Git/GitHub risk.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Self-use runs continue to start with read-only status checks without extra approval loops.
- Git/GitHub mutation and remote metadata commands remain behind policy review.

## Failure Signals

- Agents treat `git status --short` as blocked by the short reminder.
- Agents interpret the narrower reminder as permission to stage, commit, push, or read remote metadata without policy review.

## Result

Unjudged.
