# Development Loop

## Principle

Every iteration should improve the AI agent's ability to make a safer next move.

If a scanner or report section does not affect AI behavior, defer it.

## Iteration Loop

1. Choose one coherent AI decision or safety risk to improve.
2. Add or adjust scan data needed for that decision.
3. Update `scan_result.json`.
4. Update `agent_context.md` or `command_policy.md`.
5. Add fixture tests and snapshot tests.
6. Check that no secret values are read.
7. Record meaningful architecture decisions as ADRs.

## Automation Cycle Size

The default automation cadence is one hour.

Use that hour for a complete, verified development slice, not only the smallest possible edit. A good one-hour slice may include multiple tightly related changes when they serve the same AI-facing decision, such as:

- scanner data plus generated Markdown policy changes
- missing-tool behavior plus fixture and snapshot coverage
- previous-scan comparison logic plus documentation of the agent impact
- secret-safety detection plus regression tests proving values are not emitted

Keep the slice focused enough to review and revert. Avoid broad scanner expansion, unrelated cleanup, or speculative architecture work just because there is more time.

If a useful improvement is larger than one hour, split it at an artifact boundary: scan data first, generated guidance second, broader fixtures or ADRs third.

## v0.3 Automation Handoff

Use this handoff when starting automated work after the public `v0.2.0 Developer Preview`:

```text
Start v0.3 work from the current public v0.2.0 Developer Preview. Keep released tags immutable.

Focus on Agent Behavior Evaluation:
- define representative agent tasks
- compare agent command choices with and without Habitat context
- track whether agents choose preferred commands
- track whether agents ask before Review First or Ask First commands
- track whether agents avoid Forbidden commands and secret-bearing paths
- record failures as output-contract improvements, not agent blame
- keep evidence sanitized; do not store raw prompts, secrets, shell history, clipboard contents, or private local paths
- update docs/evaluation.md, fixtures, tests, or generated guidance when evaluation reveals a concrete behavior gap

Avoid broad feature expansion:
- no MCP server
- no GUI
- no automatic install/update/repair
- no command enforcement
- no large multi-LLM benchmark yet
- no new ecosystem breadth unless it directly improves a measured command decision

When generated output changes, update tests and representative examples in the same slice.
When versioned output behavior changes after a public release, do not move existing tags; use a transparent patch release.
Do not cut release tags, create GitHub Releases, or move to `v0.4` without an explicit release handoff from the user.
```

## Self-Use Before Substantial Work

Before larger Habitat changes, use the bundled `hazakura-habitat` skill or run Habitat on this repository and read the generated agent context:

```bash
swift build
./.build/debug/habitat-scan scan --project . --output ./habitat-report
```

Use `habitat-report/agent_context.md` as the working context for Codex. Consult `habitat-report/command_policy.md` before dependency, Git/GitHub, secret-adjacent, archive, copy, sync, or environment-sensitive commands.

Do not commit `habitat-report/`. Turn useful findings into docs, fixtures, tests, examples, or roadmap items. See [Self-Use Loop](self_use.md) for the current snapshot and v0.2 findings.

The intended AI-first direction is that agents trigger this scan themselves before high-impact work. Humans should not need to remember the preflight every time.

The v0.3 acceptance question is:

> Does this show that Habitat changes or constrains the agent's next command in a useful, conservative way?

For search commands, evaluate the command shape, not only whether search was used. `rg <pattern>` should remain a reasonable read-only next command when no secret-bearing files are detected. When secret-bearing files are detected, the next command should become safer, such as `rg <pattern> --glob '!.env' --glob '!.env.*' --glob '!.npmrc'`, or the agent should inspect `command_policy.md` before recursive search. The goal is to make exploration safer, not to ban search outright.

If not, keep it out of v0.3.

## Phase Gate

Automation may keep improving release candidates, but it must not decide that a release milestone is complete by itself.

Release and phase-transition work requires an explicit user handoff:

- cut or tag any release
- write GitHub Release notes
- upload or verify release artifacts
- switch automation from `v0.3` to `v0.4`
- start broad `v0.4` policy-engine work

Before that handoff, automation should keep changes inside the `v0.3` Agent Behavior Evaluation scope.

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

## Current Repository Convention

- Commit complete, tested development slices directly to `main`.
- Prefer `swift test` before committing core changes.
- Push after each complete development slice.
- Use feature branches only when a change is large, risky, or needs review before landing.
- Keep generated reports, build output, and release artifacts out of git unless they are intentional fixtures.

## Review Checklist

- Is this for AI behavior or just human curiosity?
- Is this too verbose for `agent_context.md`?
- Should this be raw JSON only?
- Does this create false certainty?
- Does this reveal secret values?
- Does this make the CLI or schema unstable?
