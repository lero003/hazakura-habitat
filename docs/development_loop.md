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

## Post-v0.3 Automation Handoff

Use this handoff when starting automated work after the public `v0.3.0 Developer Preview`:

```text
Start post-v0.3 work from the current public v0.3.0 Developer Preview. Keep released tags immutable.

Focus on the self-use observation loop:
- use Habitat during real Codex work on this repository
- observe what changed the next command, where the policy over-constrained useful work, and where the agent misunderstood guidance
- keep each automation slice small, verifiable, and commit/push oriented
- feed findings back into policy wording, reason-code structure, behavior evidence, tests, or docs
- record behavior-level evidence only when it adds a new command-decision boundary, regression, over-constraint, or concrete artifact improvement
- keep evidence sanitized; do not store raw prompts, secrets, shell history, clipboard contents, private local paths, or release credentials
- prefer the `v0.4` Policy Finding Foundation and later evidence normalization over broad feature expansion
- if a code change affects generated output, update representative examples and tests in the same slice

Avoid broad feature expansion:
- no MCP server
- no GUI
- no automatic install/update/repair
- no command enforcement
- no large multi-LLM benchmark yet
- no new ecosystem breadth unless it directly improves a measured command decision observed during self-use
- no release tags, GitHub Releases, or release asset changes without an explicit release handoff

When versioned output behavior changes after a public release, do not move existing tags; use a transparent patch release only when the published artifact would otherwise mislead users.
```

## Self-Use Before Substantial Work

Before larger Habitat changes, use the bundled `hazakura-habitat` skill or run Habitat on this repository and read the generated agent context:

```bash
swift build
./.build/debug/habitat-scan scan --project . --output ./habitat-report
```

If SwiftPM fails in a restricted automation sandbox before project code runs because of host cache or SwiftPM sandbox-wrapper errors, keep the same preferred SwiftPM verification path and retry with a writable process-local module cache plus `--disable-sandbox`. Do not substitute dependency resolution, package installs, global cache cleanup, or release/GitHub mutations for verification.

Use `habitat-report/agent_context.md` as the working context for Codex. Consult `habitat-report/command_policy.md` before dependency, Git/GitHub, secret-adjacent, archive, copy, sync, or environment-sensitive commands.

Do not commit `habitat-report/`. Turn useful findings into docs, fixtures, tests, examples, or roadmap items. See [Self-Use Loop](self_use.md) for the current snapshot and v0.2 findings.

The intended AI-first direction is that agents trigger this scan themselves before high-impact work. Humans should not need to remember the preflight every time.

## Nenrin Observation Ledger

Use `nenrin/` to track whether changes to Habitat's agent-facing working environment actually improved later agent behavior.

Before substantial self-use, automation, release-prep, or docs workflow changes, read `nenrin/index.md` after the Habitat scan context. If the task changes docs, skills, handoff guidance, roadmap, release rules, QA criteria, or automation prompts, create or update a Nenrin change record. If the task exercises an active change, create a Nenrin observation record after the work.

Keep this loop lightweight. Nenrin is for the retrospective question: did this improvement help enough to keep, remove, merge, narrow, or move it?

The post-v0.3 acceptance question is:

> Did this self-use slice reveal a concrete command-decision improvement, over-constraint, or misunderstanding that should return to policy, evidence, tests, or docs?

For search commands, evaluate the command shape, not only whether search was used. `rg <pattern>` should remain a reasonable read-only next command when no secret-bearing files are detected. When secret-bearing files are detected, the next command should become safer, such as `rg <pattern> --glob '!.env' --glob '!.env.*' --glob '!.npmrc'`, or the agent should inspect `command_policy.md` before recursive search. The goal is to make exploration safer, not to ban search outright.

If not, keep it out of the current cycle.

## Phase Gate

Automation may keep improving release candidates, but it must not decide that a release milestone is complete by itself.

Release and phase-transition work requires an explicit user handoff:

- cut or tag any release
- write GitHub Release notes
- upload or verify release artifacts
- expand or re-scope `v0.4` beyond the Policy Finding Foundation

Before that handoff, automation should keep changes inside the post-`v0.3` self-use observation loop.

Post-`v0.3` evidence may still change what should happen next. Do not assume `v0.4`, `v0.5`, or `v0.6` must happen in the current roadmap order if observed behavior points elsewhere.

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
