# Self-Use Loop

Hazakura Habitat should be used by Codex before substantial work on Hazakura Habitat itself.

This is not a marketing demo. It is a product feedback loop: if the generated context does not help an AI coding agent choose a better next command in this repository, the output contract needs work.

## Workflow

For recurring agent work, prefer the bundled skill at `skills/hazakura-habitat`. It lets Codex decide when to scan before substantial work instead of waiting for a human to remember the step.

Install from GitHub with:

```bash
npx skills add lero003/hazakura-habitat@hazakura-habitat -g
```

Run a local build first, then scan the repository:

```bash
swift build
./.build/debug/habitat-scan scan --project . --output ./habitat-report
```

When the skill is available, the equivalent helper is:

```bash
skills/hazakura-habitat/scripts/run_habitat_scan.sh .
```

Read the generated files before continuing:

- `habitat-report/agent_context.md` for the short working context.
- `habitat-report/command_policy.md` before dependency, Git/GitHub, secret-adjacent, archive, copy, sync, or environment-sensitive commands.
- `habitat-report/environment_report.md` only when audit or debug detail is needed.

Do not commit `habitat-report/`. Convert useful findings into docs, fixtures, tests, examples, or roadmap items.

## Current Self-Scan Snapshot

Snapshot date: 2026-05-02.

Observed output from scanning this repository:

- Package manager: SwiftPM.
- Preferred commands: `swift test`, `swift build`.
- `agent_context.md`: 33 lines in `scan_result.json` artifact metadata.
- `command_policy.md`: 798 lines in `scan_result.json` artifact metadata.
- `environment_report.md`: 75 lines in `scan_result.json` artifact metadata.
- Ask First commands: 262.
- Forbidden commands: 489.
- `scan_result.json` `policy.commandCounts`: 2 preferred, 262 Ask First, 489 Forbidden, 751 with reasons.
- `scan_result.json` `policy.reasonCodes`: 13 reason families, including `ephemeral_package_execution`.
- Warnings: none.

Missing Python, pip, uv, pyenv, and Go commands were recorded as diagnostics in machine-readable data, but they did not pollute `agent_context.md` because they were not relevant to the SwiftPM command decision.

## What Worked

- The first screen tells Codex to use SwiftPM and prefer `swift test` and `swift build`.
- The generated context asks before dependency resolution, lockfile mutation, and Git/GitHub mutations.
- Secret-bearing file, browser, mail, shell history, clipboard, and environment dump guidance is clear.
- Irrelevant missing-tool diagnostics stay out of the short agent context.
- The generated command policy states that it is advisory and does not block commands.
- The generated command policy now has a compact `Policy Index` with section counts before the long command lists.
- `Review First` now carries reason codes, keeps Git/GitHub mutation guards ahead of broad baseline package-manager guards, and the `Reason Codes` legend gives compact explanations without expanding `agent_context.md`.
- Full `Ask First` and `Forbidden` entries now carry reason code annotations, so long policy lists remain explainable at the point of use.
- The `agent_context.md` Ask First overflow line now names the leading hidden reason codes, so Codex can tell whether hidden approval rules are dependency, Git, or other safety guards before opening the full policy.
- Ephemeral package execution commands now carry their own `ephemeral_package_execution` reason code, so `npx`/`dlx`/`uvx`/`pipx run` guards no longer collapse into generic approval metadata.
- `scan_result.json` now records generated Markdown artifact roles, agent reading role, read order, line counts, the `agent_context.md` line limit, and whether line-limited outputs are within budget, so agents can identify and read the short working context first without parsing every report.
- `scan_result.json` now records `policy.commandCounts`, so agents can see policy size and reason coverage before deciding whether to inspect the full `command_policy.md`.
- The bundled helper must use the current source checkout for self-scans instead of silently falling back to `dist/`, otherwise a stale local release artifact can hide new output-contract sections.

## v0.2 Findings

The self-scan supports the v0.2 Output Contract Hardening focus.

Keep:

- `agent_context.md` short and command-changing.
- Missing-tool diagnostics available in audit or JSON data without making the short context noisy.
- Advisory-only wording in generated policy output.

Improve:

- Make `command_policy.md` easier to navigate when it is hundreds of lines long.
- Separate project-relevant policy from broad baseline safety policy more clearly.
- Continue reason-code groundwork so large policy sections are explainable and eventually groupable.
- Keep Git/GitHub mutation guards visible before broad baseline package-manager guards when reviewing the full command policy.
- Continue output shape metadata and tests that catch growth before it becomes normal.
- Update representative examples whenever generated output wording or structure changes.

## Acceptance Question

After reading `agent_context.md`, would Codex choose a better next command?

If `command_policy.md` is needed, can Codex find the relevant rule quickly enough to act conservatively?
