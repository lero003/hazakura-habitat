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

Automation cadence is deliberately adjustable. Use lower-frequency runs when
the project is in post-release observation mode, when recent slices are mostly
confirming stable behavior, or when the next useful command-decision gap is not
yet clear. Increase cadence only when there is fresh evidence that tighter
feedback would change the next command or close a concrete release, safety, or
output-contract risk.

Use each run for a complete, verified development slice, not only the smallest
possible edit. A good slice may include multiple tightly related changes when
they serve the same AI-facing decision, such as:

- scanner data plus generated Markdown policy changes
- missing-tool behavior plus fixture and snapshot coverage
- previous-scan comparison logic plus documentation of the agent impact
- secret-safety detection plus regression tests proving values are not emitted

Keep the slice focused enough to review and revert. Avoid broad scanner expansion, unrelated cleanup, or speculative architecture work just because there is more time.

If a useful improvement is larger than one hour, split it at an artifact boundary: scan data first, generated guidance second, broader fixtures or ADRs third.

## Roadmap Feedback During Work

If a development slice shows that the roadmap is stale, over-broad, or missing a
small decision boundary, update the relevant roadmap or status document before
closing the slice.

Keep the correction narrow:

- tie it to an observed repository fact, self-use behavior, or verification result
- distinguish what changed now from what remains a later decision
- avoid reordering phases unless the new evidence changes the next useful work
- pair agent-facing workflow changes with a lightweight Nenrin record

This is part of finishing the work, not a separate planning project.

## Post-v0.6 Automation Handoff

After the `v0.6.0 Developer Preview`, recurring Habitat work should start from
the `v0.7` Distribution Foundations phase. Keep the public `v0.6.0` tag and
release assets immutable unless the user explicitly asks for a patch release.

Default priority for automation:

- first, remove friction in how agents obtain, verify, or consume Habitat output
- second, take a minimal validation-command purpose slice when it prevents a real first-command mistake
- third, keep cross-project and Nenrin evidence observational unless it changes a Habitat command decision

For validation-purpose work, do not build a broad taxonomy by default. The
current measured gap is narrower: ordinary local validation such as `swift test`
should remain distinct from release-prep or artifact validation such as
`./scripts/build_release_artifacts.sh`. If the distinction is unclear, preserve
bounded `Open uncertainty` instead of promoting a release or packaging script as
the first ordinary validation command.

For distribution work, model Habitat's own command policy philosophy. Prefer
checksum verification and explicit binary/version checks over remote script
piping, package-manager mutation, or automatic installation. Pull a read-only
MCP prototype forward only if file-based consumption becomes the measured
blocker.

Do not let external project backlogs choose Habitat work. Cross-project intake
may supply one bounded carry-back, and Nenrin may record durable judgment
changes, but neither should turn the run into broad workspace intelligence or
changelog storage.

## Historical Post-v0.5 Observation Handoff

This handoff describes the observation loop that led from the public `v0.5.0 Developer Preview` toward `v0.6.0`. Use it as historical context when reviewing that release boundary, not as the default starting prompt for new post-`v0.6` work:

```text
Start post-v0.5 work from the current public v0.5.0 Developer Preview. Keep released tags immutable.

Focus on the self-use observation loop:
- treat v0.5.0 as accepted after post-release review; do not spend automation time on rollback, hotfix, or release-note edits unless the published artifact, checksum, install instructions, or release wording is materially misleading
- use Habitat during real Codex work on this repository
- observe what changed the next command, where the policy over-constrained useful work, and where the agent misunderstood guidance
- keep each automation slice small, verifiable, and commit/push oriented
- feed findings back into policy wording, reason-code structure, behavior evidence, tests, or docs
- record behavior-level evidence only when it adds a new command-decision boundary, regression, over-constraint, or concrete artifact improvement
- keep evidence sanitized; do not store raw prompts, secrets, shell history, clipboard contents, private local paths, or release credentials
- use `v0.5` PolicyFinding, reason-code, command-reason, secret-bearing evidence, and documented-validation-command output to decide whether a future evidence or instruction-alignment slice is actually needed
- keep post-`v0.5` Evidence and Instruction Alignment provisional; extract one concrete normalized-evidence or instruction-drift shape from observed command behavior before generalizing
- keep the context direction narrow: `repo fact -> short annotation -> command decision`
- do not make Habitat produce plans; it may produce `Facts`, `Hints`, `Warnings`, and `Open uncertainty` annotations with coarse confidence such as `high`, `medium`, or `low`
- the first documented-validation-command slice is shipped; keep any next instruction-alignment slice similarly narrow, with no raw instruction prose, no generic prose linter, and a command decision that changes, confirms, or constrains the next action
- if choosing an instruction-alignment follow-up, note that the small `xcodebuild test` validation-claim case is now covered by constraining agents to `xcodebuild -list` before scheme-dependent validation; multiple documented validation claims, unsupported documented workflows, and negated or obsolete validation-command text are already covered by narrow tests
- when a slice touches scanner, catalog, or test-heavy behavior, include a small local decomposition that preserves generated output
- the first `PolicyReasonCatalog` boundary slices (`PolicyReasonCatalog+Git.swift`, `PolicyReasonCatalog+EphemeralPackageExecution.swift`, `PolicyReasonCatalog+PackageRegistry.swift`, `PolicyReasonCatalog+CliAuth.swift`, `PolicyReasonCatalog+PackageManagerCredential.swift`, `PolicyReasonCatalog+CloudContainerCredential.swift`, `PolicyReasonCatalog+HostPrivate.swift`, `PolicyReasonCatalog+PackageManagerActivation.swift`, `PolicyReasonCatalog+SwiftPM.swift`, `PolicyReasonCatalog+JavaScriptPackageManager.swift`, `PolicyReasonCatalog+PythonPackageManager.swift`, `PolicyReasonCatalog+RubyPackageManager.swift`, `PolicyReasonCatalog+HostEnvironment.swift`, `PolicyReasonCatalog+Homebrew.swift`, `PolicyReasonCatalog+GoCargo.swift`, `PolicyReasonCatalog+ApplePackageManager.swift`, `PolicyReasonCatalog+SecretSearch.swift`, `PolicyReasonCatalog+WorkspaceMutation.swift`, `PolicyReasonCatalog+SshPrivateKey.swift`, and `PolicyReasonCatalog+ProjectEnvironment.swift`) are complete; future catalog slices should follow the same no-behavior-change extraction pattern, one cohesive command family at a time
- keep reason-code rule ordering, dependency-mutation fallback, remaining credential/auth command families, DSLs, plugins, and external rule formats out of catalog extraction slices
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

For future release handoffs, verify artifacts before pushing the public version tag when practical:

- run `swift test`
- run `git diff --check`
- run `./scripts/build_release_artifacts.sh`
- run `./dist/habitat-scan --version`
- run `cd dist && shasum -c SHA256SUMS`
- run the Release Artifacts workflow manually with `workflow_dispatch`, or use a disposable release-candidate tag if the manual workflow cannot exercise the tagged path

If a tag workflow fails before any GitHub Release exists, fixing main and replacing the unpublished tag target is acceptable but should be treated as a release-process recovery, not the normal path. Once a public GitHub Release exists, keep the tag and assets immutable; publish a patch release for material corrections.
```

## Cross-Project Observation

Habitat may also be used to watch another local project when that project is an active self-use source for AI-led development.

Keep this observational:

- read the other project's generated `habitat-report/agent_context.md` first
- compare it with the other project's visible repository facts when the report looks stale, weak, or over-broad
- treat the report's `Scanned at` timestamp as part of the evidence: if key project files changed after that timestamp, phrase the result as bounded stale-context uncertainty and regenerate before trusting package-manager or validation guidance
- look for command-changing signals: package-manager detection, missing preferred tools, validation-command uncertainty, secret-bearing paths, Git/GitHub risk, or stale report behavior
- feed only durable Habitat lessons back into this repository as docs, fixtures, tests, examples, or roadmap notes
- do not turn the watched project into a second Habitat workstream, do not copy raw report output into Nenrin, and do not make Habitat produce a plan for that project

The current Android-first `hazakura-ai-mobile` observation is a good example: its report was useful as a weak signal because it detected only `AGENTS.md` and `README.md`, emitted no primary package-manager guidance, and therefore kept agents on read-only inspection. A later read-only comparison found real Gradle wrapper and Kotlin build files while a fresh Habitat scan still emitted the same no-primary-package-manager guidance. The first carry-back is intentionally narrow: executable `gradlew` can now select Gradle wrapper validation and align sanitized `./gradlew test` claims with repository facts. Treat further Gradle or Android work as a new measured command-decision gap, not as permission for broad ecosystem coverage.

For recurring Habitat automation, make cross-project observation a short intake
step before choosing the slice, not a second workstream:

- inspect the watched project's current `habitat-report/agent_context.md` when it exists
- if the report is missing, stale, or contradicted by visible key files, run a fresh scan into a temporary output directory and compare only the command-changing result
- check `hazakura-ai-mobile` for Gradle wrapper, validation-command, blocker, or stale-report signals, and `hazakura-nenrin` for Python workflow, ledger, no-op, and record-pressure signals
- carry back only one bounded Habitat improvement when the observed signal changes command choice, report freshness handling, generated guidance, fixture coverage, or automation wording
- if the intake confirms current behavior, record the judgment briefly in the run report and continue with the best local Habitat slice or end as a clean no-op

Do not edit the watched project, copy raw report text into this repository, or
let the watched project's backlog choose Habitat's work. The useful shape is
still `repo fact -> short annotation -> command decision`.

## Self-Use Before Substantial Work

Before larger Habitat changes, use the bundled `hazakura-habitat` skill or run Habitat on this repository and read the generated agent context:

```bash
swift build
./.build/debug/habitat-scan scan --project . --output ./habitat-report
```

If SwiftPM fails in a restricted automation sandbox before project code runs because of host cache or SwiftPM sandbox-wrapper errors, keep the same preferred SwiftPM verification path and retry with a writable process-local module cache plus `--disable-sandbox`. Do not substitute dependency resolution, package installs, global cache cleanup, or release/GitHub mutations for verification.

Use `habitat-report/agent_context.md` as the working context for Codex. Consult `habitat-report/command_policy.md` before dependency, Git/GitHub, secret-adjacent, archive, copy, sync, or environment-sensitive commands.

Do not commit `habitat-report/`. Turn useful findings into docs, fixtures, tests, examples, or roadmap items. See [Self-Use Loop](self_use.md) for the current snapshot and v0.2 findings.

This is a high-impact preflight, not a ritual for every tiny edit. Prefer it when an agent is new to the repository, when package-manager/runtime/secret/release signals may matter, before dependency or Git/GitHub mutation, and after project guidance changes. If `AGENTS.md` and the development docs already answer the command question for a low-risk task, skipping the scan is acceptable.

The intended AI-first direction is that agents trigger this scan themselves before high-impact work. Humans should not need to remember the preflight every time. The scan is most valuable when it reports current repository facts or instruction drift that `AGENTS.md` alone cannot prove.

## Nenrin Observation Ledger

Use `nenrin/` to track whether changes to Habitat's agent-facing working environment actually improved later agent behavior.

Before substantial self-use, automation, release-prep, or docs workflow changes, read `nenrin/index.md` after the Habitat scan context. If the task changes docs, skills, handoff guidance, roadmap, release rules, QA criteria, or automation prompts, create or update a Nenrin change record. If the task exercises an active change, create a Nenrin observation record after the work.

Keep this loop lightweight. Nenrin is for the retrospective question: did this improvement help enough to keep, remove, merge, narrow, or move it?

The common handoff pattern is:

```text
Habitat scan finds or confirms a command-changing fact -> the slice changes docs, tests, examples, policy wording, or generated output -> Nenrin records why that agent-facing change should affect later behavior -> a later observation decides whether to keep, narrow, merge, or remove it.
```

Do not record raw scan output in Nenrin. Record the decision impact: what the agent would do differently, what risk was reduced, and what future evidence should confirm or reject the change.

The post-v0.5 acceptance question is:

> Did this self-use slice show that a specific scanner fact should become normalized evidence before it feeds `PolicyFinding`, rendered policy, tests, or docs?

Also ask whether the slice exposed a maintainability risk: a scanner responsibility, catalog family, or test scenario group that should be split before adding more behavior nearby.

For search commands, evaluate the command shape, not only whether search was used. `rg <pattern>` should remain a reasonable read-only next command when no secret-bearing files are detected. When secret-bearing files are detected, the next command should become safer, such as `rg <pattern> --glob '!.env' --glob '!.env.*' --glob '!.npmrc'`, or the agent should inspect `command_policy.md` before recursive search. The goal is to make exploration safer, not to ban search outright.

If not, keep it out of the current cycle.

## Phase Gate

Automation may keep improving release candidates, but it must not decide that a release milestone is complete by itself.

Release and phase-transition work requires an explicit user handoff:

- cut or tag any release
- write GitHub Release notes
- upload or verify release artifacts
- expand or re-scope post-`v0.5` evidence, instruction-alignment, or maintainability work beyond observed needs

Before that handoff, automation should keep changes inside the post-`v0.5` self-use observation loop.

Post-`v0.5` evidence may still change what should happen next. Do not assume `v0.6`, `v0.7`, or `v0.8` must happen in the current roadmap order if observed behavior points elsewhere.

For the `v0.5.0 Developer Preview` release handoff, the final claim check is:

- `SecretBearingEvidence` or another local evidence boundary is present and tested
- one instruction-alignment case compares a documented validation-command claim with repository facts
- the case changes, confirms, or constrains one next command in `agent_context.md`
- raw instruction prose is not emitted in generated artifacts
- `HabitatMetadata.generatorVersion`, README status, examples, changelog, release notes, and generated artifacts agree on `0.5.0`

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
- Use `./scripts/build_release_artifacts.sh` for release-prep and artifact verification, not as the normal first command for everyday code validation.
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
