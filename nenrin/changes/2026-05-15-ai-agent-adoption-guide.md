---
type: nenrin_change
id: ai-agent-adoption-guide
date: 2026-05-15
status: observing
impact: unknown
related_files:
  - README.md
  - docs/adoption_guide.md
  - docs/agent_contract.md
  - examples/README.md
  - CHANGELOG.md
review_after:
  tasks: 3
  days: 7
---

# Change: ai-agent-adoption-guide

## Changed

- Added an AI agent adoption guide with partial Habitat adoption levels.
- Linked the guide from README, the agent contract, and examples.
- Clarified that Habitat is a pre-work context layer, not a replacement for existing project docs.

## Reason

Habitat's public and project-facing direction is to be read and adopted by AI agents as a command-decision context layer. The docs needed a copyable adoption surface so agents can choose the smallest useful level instead of treating Habitat as an all-or-nothing product or a human-facing dashboard.

## Expected Behavior

- Future agents can decide whether Level 0, read-only reference, one-time preflight, skill use, scripted consumption, or feedback-loop adoption is appropriate.
- Existing repository docs remain the source of durable project rules.
- Agents copy the short Habitat instruction block instead of inventing broader setup or installer behavior.
- Agents keep Habitat at `repo fact -> short annotation -> command decision` rather than treating it as a planner.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Future repository onboarding uses the adoption guide to pick a smaller Habitat entrypoint when full integration is unnecessary.
- Agents cite `agent_context.md` first and consult `command_policy.md` before risky commands.
- Web or README readers describe Habitat as an AI-facing pre-execution context protocol rather than a human dashboard.

## Failure Signals

- Agents still replace or duplicate existing project docs with Habitat output.
- The adoption guide causes unnecessary full integration when a lower level would do.
- Future docs drift back toward broad philosophy without copyable command-decision instructions.

## Result

Unjudged.
