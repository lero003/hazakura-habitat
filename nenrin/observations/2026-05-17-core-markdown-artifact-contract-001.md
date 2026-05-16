---
type: nenrin_observation
id: core-markdown-artifact-contract-001
date: 2026-05-17
related_changes:
  - core-markdown-artifact-contract
  - scan-result-stability-boundary
impact_judgment: unknown
success_tags:
  - stable_boundary_tested
  - preview_scope_preserved
failure_tags: []
---

# Observation: core-markdown-artifact-contract-001

## Task

Recurring Habitat `v0.9` Pre-1.0 hardening loop.

## Observed Behavior

- A fresh self-scan confirmed the current generated read order:
  `agent_context.md` first, `command_policy.md` before risky commands, and
  `environment_report.md` only for diagnostics.
- The next useful hardening slice was not a generated-output change; it was to
  separate the narrow stable-candidate Markdown artifact metadata from
  preview-only navigation and sizing metadata in test coverage and docs.
- The new contract test pins only the stable-candidate fields that helpers and
  agents use for artifact trust, leaving exact section lines, counts, and
  broader JSON shape preview-scoped.

## Success Signals Observed

- The slice did not broaden `scan_result.json` stability.
- Generated artifact content and representative examples were left unchanged.
- The docs now name the same stable-candidate fields that the test protects.

## Failure Signals Observed

- None in this run.

## Impact Judgment

unknown

## Next Action

- Rejudge after a later helper, release-consumption, or agent-adoption slice
  uses the stable artifact contract without depending on preview-only fields.
