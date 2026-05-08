---
type: nenrin_change
id: ci-workflow-local-validation-uncertainty
date: 2026-05-08
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/CiPresenceDetector.swift
  - Sources/HabitatCore/Models.swift
  - Sources/HabitatCore/Scanner.swift
  - Sources/HabitatCore/ReportWriter.swift
  - Tests/HabitatCoreTests/InstructionAlignmentPolicyTests.swift
  - examples/behavior-evaluation/ci-workflow-no-local-validation-001.json
  - examples/swift-package/scan_result.json
  - CHANGELOG.md
  - docs/agent_contract.md
  - docs/evaluation.md
  - docs/current_status.md
  - docs/roadmap.md
  - docs/self_use.md
review_after:
  tasks: 3
  days: 7
---

# Change: ci-workflow-local-validation-uncertainty

## Changed

- Added GitHub Actions workflow filename detection to `ProjectInfo`.
- Added a short `Open uncertainty` annotation when CI configuration exists but repository facts do not identify a concrete local verification command.
- Added instruction-alignment tests and a behavior-evaluation fixture for the CI-without-local-validation command decision.

## Reason

CI presence is a useful repository fact, but deriving a local command from workflow YAML is too confident for the current evidence model. The safer command decision is to tell the agent that CI exists while refusing to invent `npm test`, `make test`, or similar local validation without repository support.

## Expected Behavior

- Agents do not infer local validation commands solely from `.github/workflows/*.yml` presence.
- Agents use read-only inspection to confirm supported local commands when CI exists but package-manager or documented validation facts are absent.
- Workflow contents stay out of generated agent-facing guidance.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Future no-package-manager repositories with CI lead agents to verify local command support before running tests.
- CI evidence remains a small filename signal unless repeated behavior evidence justifies deeper workflow parsing.

## Failure Signals

- Agents still treat CI existence as permission to run an inferred local test command.
- The CI signal grows into broad YAML parsing before a command-changing case justifies it.

## Result

Unjudged.
