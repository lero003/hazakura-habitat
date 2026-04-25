# Development Loop

## Principle

Every iteration should improve the AI agent's ability to make a safer next move.

If a scanner or report section does not affect AI behavior, defer it.

## Iteration Loop

1. Choose a narrow AI decision to improve.
2. Add or adjust scan data needed for that decision.
3. Update `scan_result.json`.
4. Update `agent_context.md` or `command_policy.md`.
5. Add fixture tests and snapshot tests.
6. Check that no secret values are read.
7. Record meaningful architecture decisions as ADRs.

## Definition of Done

A change is done when:

- Missing tools are handled gracefully
- Partial scan results still produce artifacts
- Output stays concise and actionable
- Tests cover success and failure paths
- The command policy remains read-only and conservative
- The generated agent context changes at least one plausible AI decision

## Safety Rules

Do not implement or run:

- `sudo`
- package install/update/delete commands
- global environment mutation commands
- background monitoring
- secret file value reading

Allowed scanner commands must be read-only, bounded, and timeout-protected.

## Review Checklist

- Is this for AI behavior or just human curiosity?
- Is this too verbose for `agent_context.md`?
- Should this be raw JSON only?
- Does this create false certainty?
- Does this reveal secret values?
- Does this make the CLI or schema unstable?

