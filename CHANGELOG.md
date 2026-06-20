# Changelog

## Unreleased

- No changes yet.

## v1.1.0 - 2026-06-21

Post-v1 observation hardening release.

`v1.1.0` keeps Habitat advisory, read-only, and macOS-first while carrying
forward real self-use observations into scanner freshness, validation-claim
handling, documentation, fixtures, and repository maintenance.

### Changed

- Added `docs/current-work.md` and `docs/current-status.md` as bounded
  project-guidance freshness inputs and sanitized validation-command claim
  sources, matching current Hazakura Editor usage.
- Recognized `Verification` headings and selected package.json-backed package
  scripts such as `npm run build:vite` as validation-command claims without
  promoting broader release or planning prose.
- Added `hazakura-note` / `hazakura editor` as a bounded cross-project
  observation source for the post-v1 automation loop, treating its npm + Cargo
  validation-flow uncertainty as intake evidence rather than a watched-project
  workstream or immediate scanner expansion.
- Clarified the `v1.0.x` observation-ledger roadmap so Nenrin's current
  post-v1 shape is visible but sparse, narrowed to the thin observation spine
  instead of an unresolved product-surface choice.
- Clarified the cross-project observation example so the older Android
  no-primary-package-manager signal does not override the current project-local
  wrapper guidance.
- Narrowed the post-`v1.0.0` Nenrin ledger guidance so routine docs edits,
  verified no-ops, and already-covered observations do not create records unless
  they change a later command-decision, freshness, generated-guidance, fixture,
  helper, automation-wording, or pruning judgment.
- Added a post-`v1.0.0` behavior fixture for external web cleanup reports,
  preserving the useful Node runtime / `npm run build` / mutation-guard signal
  while keeping dead asset detection, CSS dead-code scanning, and automatic
  re-scan hooks parked until command-decision evidence justifies them.
- Added repository follow-up safeguards for post-`v1.0.0` use: CODEOWNERS,
  Dependabot version-update coverage for GitHub Actions and SwiftPM, local
  secret/credential ignore patterns, and clearer agent-skill install review
  wording.
- Added post-`v1.0.0` automation guidance that narrows automatic work toward
  observation-led policy tuning, minimal freshness guards, and lightweight
  Nenrin judgment records before broader integration or distribution work.
- Classified the observed macOS app `./script/build_and_run.sh --verify`
  command as `launch_smoke`, keeping launch-smoke checks out of ordinary local
  validation preference.
- Clarified post-`v1.0.0` docs wording for the `v1.x` deprecation posture, the
  narrow stable machine-readable boundary, release-binary versus source-build
  requirements, and post-v1 observation language.
- Aligned the self-use historical snapshot handoff with the current post-v1
  observation loop so recurring work does not reopen `v1.0` readiness.

### Verified

- `swift test`
- `git diff --check`
- Local release artifacts built with `scripts/build_release_artifacts.sh`.
- Local checksums verified with `cd dist && shasum -c SHA256SUMS`.
- Local release helper verification with
  `scripts/verify_habitat_release.sh ./dist . 1.1.0`.

## v1.0.0 - 2026-05-18

Stable advisory generator release.

`v1.0.0` keeps Habitat narrow: advisory, read-only, macOS-first, and focused on
helping AI coding agents choose a safer next command. This release does not add
command enforcement, sandboxing, broad platform support, MCP integration, a GUI,
automatic repair, or a generic evidence layer.

### Changed

- Anchored the `v1.x` compatibility posture in the agent contract:
  `schemaVersion` gates unsafe preview-format changes, `generatorVersion`
  remains release provenance, additive preview fields may continue, and removals
  should prefer documented deprecation before schema changes.
- Clarified post-`v1.0.0` automation guidance so recurring runs treat the
  release as complete, use repo docs as the current authority when saved prompts
  lag, and select only observation-backed hardening gaps or verified no-op.
- Reframed the post-`v1.0` roadmap as an observation roadmap: deepen bounded
  core evidence before thin integration, keep platform expansion in the parking
  lot, and keep observation-led follow-ups such as Nenrin, representative
  examples, no-scan cases, Linux notes, and MCP evidence-gated rather than
  default feature lanes.
- Promoted the generator version and public docs to `1.0.0` while keeping the
  stable machine-readable boundary narrow: the core Markdown artifact reading
  contract is stable, while detailed JSON counts, section navigation, policy
  reason details, previous-scan values, and project metadata remain
  preview-scoped.

### Verified

- `swift test`
- `git diff --check`
- Local release artifacts built with `scripts/build_release_artifacts.sh`.
- Local checksums verified with `cd dist && shasum -c SHA256SUMS`.
- Local release helper verification with
  `scripts/verify_habitat_release.sh ./dist . 1.0.0`.

## v0.9.0 Developer Preview - 2026-05-17

Pre-1.0 hardening release.

`v0.9.0` sorts the first narrow stability boundaries before `v1.0`.
Habitat remains advisory, read-only, and macOS-first; this release does not add
command enforcement, sandboxing, broad platform support, MCP integration, or a
new scanner domain.

### Changed

- Clarified the `scan_result.json` v0.9 boundary so core Markdown artifact
  metadata is treated as a narrow v1-stable candidate while detailed navigation
  and previous-scan value metadata remain preview-scoped.
- Changed previous-scan comparison so mismatched `schemaVersion` reports stop at
  schema/generator compatibility deltas instead of emitting lower-level
  package, freshness, preferred-command, or policy changes from an incompatible
  previous schema.
- Changed previous-scan comparison so mismatched `generatorVersion` reports stop
  at the generator boundary instead of mixing generator-shape drift with
  lower-level environment, preferred-command, or policy deltas.
- Added an agent-contract failure-mode table for `v0.9` so checksum,
  metadata, stdout/output, previous-scan, freshness, and diagnostic-report
  mismatches resolve to explicit failure, bounded uncertainty, or docs-only
  misuse.
- Hardened previous-scan structured values for package-manager version,
  runtime-hint, sensitive-signal, project-symlink, missing-tool,
  tool-verification, preferred-command, and command-policy deltas so scripts can
  inspect `previousValues` / `currentValues` without scraping prose.
- Normalized previous-scan schema and generator labels before rendering
  compatibility-boundary summaries, so malformed external previous-scan metadata
  does not inject raw multiline labels into generated Markdown.
- Kept unreadable previous scans as bounded uncertainty rather than scan
  failure, preserving current generated guidance while telling agents to pass a
  readable previous report before relying on comparison output.
- Added generated-artifact coverage for generator-version deltas so
  `scan_result.json`, `agent_context.md`, and `environment_report.md` all expose
  the same bounded generator-change boundary.
- Tightened local/release metadata helpers so generated Markdown artifact
  checks include entry sections, the `agent_context.md` line budget, and
  matching stdout filename aliases.
- Clarified `v0.9` automation guidance so recurring runs classify stable,
  preview, docs-only, and post-v1 boundaries instead of creating changes just
  because the loop ran.
- Added `hazakura-llm-manager` to the bounded cross-project Habitat intake
  guidance as a SwiftPM macOS-app usage source.
- Clarified README/product-direction positioning around Habitat as
  evidence-backed, bounded first-pass repository guidance for AI agents, not
  broad language or environment coverage.
- Added large-repository development guidance that favors scoped entrypoints,
  nearby files, command-relevant evidence, and explicit uncertainty over
  whole-project interpretation.
- Updated generated artifact metadata to report generator version `0.9.0`.

### Verified

- `swift test --disable-sandbox` passes with 368 tests in 34 suites.
- `git diff --check` passes for the release-prep tree.
- Local release artifacts were built with `scripts/build_release_artifacts.sh`,
  checksummed with `shasum -c dist/SHA256SUMS`, and verified with
  `scripts/verify_habitat_release.sh ./dist . 0.9.0`.

## v0.8.0 Developer Preview - 2026-05-16

Observation -> Action hardening release.

`v0.8.0` tightens Habitat after the `v0.7` distribution work by making
saved-report reuse, previous-scan comparison, report freshness, preferred
command changes, and generated context traceability more visible to agents and
local scripts. Habitat remains advisory, read-only, and macOS-first; this
release does not add command enforcement, sandboxing, broad platform support,
or a new scanner domain.

### Added

- Added previous-scan support to the bundled `hazakura-habitat` skill helper,
  including automatic reuse of an existing `habitat-report/scan_result.json`
  when refreshing into a separate output directory.
- Added previous-scan observed-file freshness deltas so stale saved reports can
  surface command-relevant changes in key project files without turning Habitat
  into a general file-diff dashboard.
- Added structured preferred-command deltas, including previous and current
  preferred command values, so agents can see when the likely first validation
  command changed between scans.
- Added structured command-policy transition deltas for previous-scan
  comparison, making policy additions, removals, and classification changes
  easier to review as command-decision signals.
- Added the Habitat generator version to `agent_context.md` notes so short
  AI-facing context can be traced back to the generator that produced it.
- Added an AI agent adoption guide that defines partial Habitat adoption levels,
  copyable agent instructions, and boundaries for using Habitat without
  replacing existing project docs.

### Changed

- Improved the bundled skill helper so Habitat source checkouts prefer the
  freshly built local `./.build/debug/habitat-scan`, use unique temporary report
  output paths, and print canonical generated report paths after a scan.
- Clarified the post-`v0.7` roadmap so the first `v0.8` work is Observation ->
  Action hardening, not broad scanner expansion.
- Separated the observed `./scripts/dev-env-check.sh` environment preflight
  script from ordinary local validation claims, so it is not promoted as a
  normal `Prefer` command when a project also documents its real validation
  wrapper.
- Clarified validation-purpose guidance around ordinary local validation,
  release/artifact validation, device verification, and environment checks
  where those distinctions affect first-command guidance or bounded
  uncertainty.
- Clarified README release consumption wording to say Developer Preview GitHub
  Release and clarified that `docs/public_readiness.md` is the historical
  first-public audit trail, not the active release checklist for current
  Developer Preview releases.
- Updated generated artifact metadata to report generator version `0.8.0`.

### Deferred

- Cross-project observation remains bounded and non-authoritative; watched
  repositories may supply one Habitat carry-back, but their backlogs do not
  choose Habitat work.
- Thin read-only MCP, `--format` modes, setup-guide expansion, Linux
  portability notes, and deeper setup/lint/smoke/package/CI-mirror validation
  taxonomy remain future work unless repeated observations show they change a
  command decision.

## v0.7.0 Developer Preview - 2026-05-15

Distribution Foundations release.

`v0.7.0` makes Habitat easier for agents, automations, and local scripts to
obtain, verify, and consume while preserving the advisory, read-only boundary.
`scan_result.json` remains preview metadata during `v0.x`; individual fields
may still change before `v1.0`.

### Changed

- Added `scripts/check_habitat_metadata.sh` so local scripts can compare
  `habitat-scan --version` with `scan_result.json` `generatorVersion` through
  `--stdout scan-result` without creating or updating `habitat-report/`.
- Added `scripts/print_habitat_artifact.sh` so local scripts can print one
  verified generated artifact to stdout while keeping version/schema/artifact
  metadata failures on stderr.
- Tightened `scripts/print_habitat_artifact.sh` so it rejects requested
  Markdown artifacts whose metadata has the wrong read order, read trigger, or
  agent-use hint before printing to stdout.
- Tightened `scripts/check_habitat_metadata.sh` so it also rejects unexpected
  `scan_result.json` `schemaVersion` values and prints the verified schema in
  successful script output.
- Added `scripts/verify_habitat_release.sh` so local scripts can verify
  `SHA256SUMS` before executing a downloaded release binary, then reuse the
  metadata helper without installing Habitat or creating `habitat-report/`.
- Added `scripts/print_habitat_release_artifact.sh` so local scripts can verify
  a downloaded release directory checksum-first and print one generated
  artifact to stdout without managing the extracted binary path.
- Tightened Habitat metadata and artifact helper scripts so binary paths must
  be regular non-symlink executable files before version, metadata, or artifact
  checks run.
- Tightened release-directory helper scripts so the selected zip or standalone
  binary asset must be present in `SHA256SUMS` before it can be extracted or
  executed.
- Added `docs/distribution_foundations.md` to document the supported
  consumption paths for durable reports, direct stdout artifacts, verified local
  binaries, and checksum-first release directories without adding installer or
  enforcement behavior.
- Changed direct stdout artifact aliases so `habitat-report/agent_context.md`
  style report paths are accepted alongside generated filenames, reducing
  saved-report-to-stdout plumbing in local scripts.
- Changed direct stdout artifact aliases and the verified print helper so
  absolute saved-report paths containing `habitat-report/<artifact>` are
  normalized like report-relative paths.
- Added `habitat-scan scan --stdout scan-result` so automation and local scripts can consume `scan_result.json` metadata without creating a report directory.
- Added the Hazakura Habitat logo asset and surfaced it at the top of `README.md`.
- Moved the bundled agent skill entrypoint into the top of `README.md` so AI agents can discover `skills/hazakura-habitat/SKILL.md` during an initial repository read.
- Clarified the post-`v0.6.0` roadmap handoff: `v0.7` stays focused on Distribution Foundations, with minimal validation-command purpose clarity as an early bounded slice, while deeper Observation -> Action work moves to `v0.8`.
- Updated automation-facing phase guidance so recurring Habitat work does not keep pursuing the post-`v0.5` observation loop or broaden validation taxonomy without repeated command-decision evidence.
- Clarified that `v0.7` distribution work should verify binary version, `generatorVersion`, and generated metadata, and should prefer stdout/file consumption before considering a thin read-only MCP prototype.
- Changed Python project guidance so Habitat only promotes `.venv/bin/python -m pytest` after verifying project pytest is runnable, and prefers project-virtualenv unittest when repo docs or top-level test files point to unittest.
- Updated generated artifact metadata to report generator version `0.7.0`.

## v0.6.0 Developer Preview - 2026-05-13

Agent Behavior Feedback Loop release.

`v0.6.0` turns Habitat's short command annotations into a more observable feedback loop. Generated guidance is now covered more directly by output contracts, behavior fixtures, project-local validation handling, freshness metadata, and Nenrin observations. Habitat remains advisory; it does not enforce agent behavior.

Generated Markdown and JSON guidance may differ materially from `v0.5.0`, especially around command preference reasons, review-first reasons, project-local validation scripts, freshness metadata, and bounded `Open uncertainty`.

### Changed

- Added a combined baseline command-family manifest boundary so `PolicyReasonCatalog` catalog assembly and drift tests consume one baseline family list instead of separately joining Ask First and Forbidden families.
- Split baseline lockfile, privileged-command, outside-project deletion, and secret-value static guard ownership into separate `PolicyReasonCatalog` file boundaries with no intended generated-output behavior change.
- Recorded post-`v0.5.0` review guidance in automation-facing docs: no rollback, hotfix, or release-note edit is needed for `v0.5.0`, and future instruction-alignment work should stay in narrow `v0.5.x` / `v0.6` slices.
- Clarified future release workflow guidance so release artifact builds are verified before public version tags when practical, while published releases and tags remain immutable.
- Updated the bundled `hazakura-habitat` skill so its helper retries source-checkout builds with a writable module cache and `--disable-sandbox`, and so the skill preserves the post-`v0.5` / `v0.6` observation feedback loop.
- Added a `PolicyOutputContractTests` contract that verifies `scan_result.json` reason-code legend metadata covers every serialized command-reason and Review First reason code.
- Added a `PolicyOutputContractTests` contract that verifies serialized command-reason text matches the matching `policy.reasonCodes` legend text.
- Added a `PolicyOutputContractTests` contract that verifies `command_policy.md` `Reason Codes` lines stay in sync with serialized `policy.reasonCodes` metadata.
- Added a `PolicyOutputContractTests` contract that keeps generic Ask First and Forbidden fallback reason codes present in `policy.reasonCodes`.
- Added a `PolicyOutputContractTests` budget contract that keeps full `command_policy.md` approval detail from growing past the preview readability threshold without an explicit test update.
- Added a `PolicyOutputContractTests` contract that verifies `command_policy.md` `Review First` lines stay in sync with serialized `policy.reviewFirstCommandReasons` metadata.
- Added a `PolicyOutputContractTests` contract that verifies `command_policy.md` `Review First` remains the reasoned prefix of the rendered `Ask First` list.
- Added a `PolicyOutputContractTests` contract that verifies `command_policy.md` `Policy Index` counts stay in sync with generated policy metadata and section contents.
- Added a `PolicyOutputContractTests` contract that verifies `command_policy.md` `Policy Index` ordering follows the rendered policy section order.
- Added a `PolicyOutputContractTests` contract that verifies `command_policy.md` `Policy Index` omits absent conditional sections instead of pointing agents at empty headings.
- Added a `PolicyOutputContractTests` contract that verifies `command_policy.md` `Ask First` and `Forbidden` reason-code annotations stay in sync with serialized `policy.commandReasons` metadata.
- Added a `PolicyOutputContractTests` contract that verifies `command_policy.md` `Ask First` ordering keeps secret-bearing search, missing-tool, selected package-manager, lockfile, and Git risks in priority order.
- Changed `command_policy.md` `Policy Index` wording so `Allowed` entries are described as safe starting points, not only concrete commands.
- Added an `AgentContextOutputContractTests` contract that keeps hidden Ask First overflow summaries bounded to the first three structured reason codes plus `more`.
- Changed `agent_context.md` Ask First overflow counts so Git/GitHub guards summarized by the dedicated mutation reminder are not counted again in the additional hidden-command line.
- Added an `AgentContextOutputContractTests` contract that keeps summarized Git/GitHub mutation guards discoverable as concrete `Review First` entries in `command_policy.md`.
- Added a `PolicyReasonCatalogTests` contract that keeps generic dependency-mutation fallback behind specific command-family rules.
- Added a `PolicyReasonCatalogTests` contract that keeps dependency-shaped package registry, Corepack activation, and ephemeral execution commands ahead of generic dependency-mutation fallback.
- Added a `PolicyReasonCatalogTests` contract that keeps the whole package-registry mutation command family on `package_registry_mutation` reason metadata.
- Added a `PolicyReasonCatalogTests` contract that keeps selected package-manager Review First routing limited to non-duplicated baseline Ask First commands, with SwiftPM dependency-resolution commands pinned as the explicit selected-workflow exception.
- Added a `PolicyReasonCatalogTests` contract that keeps static command-family catalogs covered by the baseline Ask First and Forbidden lists while leaving dynamic SwiftPM and secret-bearing search guards out of the static baseline.
- Added a `PolicyReasonCatalogTests` contract that keeps catalog command-family arrays free of duplicate commands before they are assembled into generated policy.
- Added a `PolicyReasonCatalogTests` contract that keeps specific Forbidden reason families ahead of the generic unsafe-command fallback.
- Changed secret-bearing broad-search guidance so generated `rg --glob` and `git grep` pathspec examples shell-quote detected paths with apostrophes safely.
- Added a pre-commit configuration warning in `agent_context.md` and `PreCommitPolicyTests` coverage so agents check `git status` after commit hooks may mutate the workspace.
- Added a `PolicyReasonCatalogTests` contract that keeps GitHub CLI local workspace commands under `git_mutation` while remote GitHub actions stay under `remote_repository_action`.
- Changed workspace mutation reason-code routing so `rm`, `rm -r`, `rm -rf`, and `xargs rm` use `user_approval_required` instead of falling through to dependency-mutation reasoning.
- Added CI workflow presence to scan data and `agent_context.md` uncertainty when CI exists but repository facts do not identify a local verification command.
- Changed documented validation-command alignment so multiple instruction files that point to different validation workflows emit bounded `Open uncertainty` instead of silently trusting the first claim.
- Changed documented validation-command extraction so negated, obsolete, or example-only command mentions are not recorded as positive validation claims.
- Changed documented validation-command extraction so release-artifact or packaging scripts are not promoted as ordinary local validation commands merely because they live under `./scripts/`.
- Changed documented validation-command alignment so a documented workflow with no repository-supported workflow emits bounded `Open uncertainty` instead of a confident mismatch warning.
- Changed documented Xcode validation alignment so `xcodebuild test` claims are constrained to `xcodebuild -list` scheme discovery before following the documented test command.
- Documented a cross-project observation boundary for using another local project's `habitat-report/` as self-use input without turning Habitat into a planner or a second workstream for that project.
- Updated generated artifact metadata to report generator version `0.6.0`.

## v0.5.0 Developer Preview - 2026-05-08

Evidence and Instruction Alignment release.

### Added

- Added `ValidationCommandClaim` scan data for sanitized validation-command claims from allowlisted instruction files, storing only source filename and normalized command.
- Added `DocumentedValidationCommandEvidence` to compare documented validation-command claims with repository facts and render short `Fact`, `Warning`, and `Hint` annotations in `agent_context.md`.
- Added `InstructionAlignmentPolicyTests.swift` coverage for conflicting and matching documented validation-command claims, raw-prose non-emission, and avoiding build-command false positives without validation context.
- Added `examples/behavior-evaluation/instruction-claim-validation-001.json` as the first observed instruction-claim versus repository-facts fixture.

### Changed

- Updated generated artifact metadata to report generator version `0.5.0`.
- Split the baseline Forbidden command list into smaller typed components so release builds type-check reliably on GitHub Actions without changing generated policy behavior.
- Clarified post-`v0.4.0` documentation so the next cycle observes published PolicyFinding behavior before starting broad evidence or instruction-alignment work.
- Added roadmap guardrails for Scanner/test/catalog maintainability, `v0.5` entry criteria, non-Habitat behavior evidence, read-only MCP timing, Linux feasibility, and release distribution trust.
- Clarified the `v0.5` direction as short, evidence-backed context annotations (`Facts`, `Hints`, `Warnings`, and `Open uncertainty`) rather than plan generation or a broad upfront `NormalizedEvidence` layer.
- Clarified the final `v0.5.0` release gate: add one instruction-alignment slice that checks a documented validation-command claim against repository facts and changes, confirms, or constrains the next command without quoting raw project prose.
- Clarified the initial pre-`v0.5` maintainability slice for extracting Git/GitHub command families from `PolicyReasonCatalog` without behavior changes, while leaving rule ordering, fallback behavior, remaining credential/auth families, DSLs, plugins, and external rule formats untouched.
- Updated release-install guidance to explain that full `SHA256SUMS` verification expects all generated release assets in the same directory.
- Extracted `SecretFileDetector` from `Scanner.swift` (~300 lines), leaving Scanner at 1548 lines and giving secret detection a clear module boundary.
- Split monolithic `HabitatCoreTests.swift` (8628 lines) into scenario-grouped test suites: `CoreInfrastructureTests`, `BehaviorEvaluationTests`, `SecretFileDetectionTests`, `ScanComparisonTests`, `JavaScriptMetadataPolicyTests`, `PolicyReasonCatalogTests`, `PolicyOutputContractTests`, and `SwiftPackagePolicyTests`, with shared helpers in `TestHelpers.swift`. 211 tests pass across 8 suites.
- Split `PolicyReasonCatalogTests.swift` out of `PackageAndCommandPolicyTests.swift` for catalog-family classification contracts with no intended behavior change.
- Split `PolicyOutputContractTests.swift` out of `PackageAndCommandPolicyTests.swift` for policy metadata, command-reason, older-JSON decoding, and reason-legend ordering contracts with no intended behavior change.
- Split `SwiftPackagePolicyTests.swift` out of `PackageAndCommandPolicyTests.swift` for SwiftPM and Xcode command-selection contracts with no intended behavior change.
- Split `WorkspaceMutationPolicyTests.swift` out of `PackageAndCommandPolicyTests.swift` for Git/workspace mutation, permission, copy/archive, and project-outside deletion policy contracts with no intended behavior change.
- Split `GoCargoPolicyTests.swift` out of `PackageAndCommandPolicyTests.swift` for Go/Cargo missing-tool, version-check, and Review First ordering contracts with no intended behavior change.
- Split `RubyBundlerPolicyTests.swift` out of `PackageAndCommandPolicyTests.swift` for Bundler signal, mutation, config, version-check, and Ruby version-hint contracts with no intended behavior change.
- Split `HomebrewApplePolicyTests.swift` out of `PackageAndCommandPolicyTests.swift` for Homebrew Bundle, Homebrew host-state, CocoaPods, and Carthage scanner policy contracts with no intended behavior change.
- Split `PythonPackagePolicyTests.swift` out of `PackageAndCommandPolicyTests.swift` for Python, pip, uv, virtual-environment, and Python runtime-hint scanner policy contracts with no intended behavior change.
- Split `JavaScriptPackagePolicyTests.swift` out of `PackageAndCommandPolicyTests.swift` for JavaScript package-manager selection, Node/runtime guard, lockfile conflict, workspace, and package-manager field scanner policy contracts with no intended behavior change.
- Split `JavaScriptCommandPolicyTests.swift` out of `PackageAndCommandPolicyTests.swift` for JavaScript missing-tool, dependency-mutation, global-install, and Corepack command-safety contracts with no intended behavior change.
- Split `PackageRegistryPolicyTests.swift` out of `PackageAndCommandPolicyTests.swift` for ephemeral package execution and package-registry mutation scanner policy contracts with no intended behavior change.
- Split `CredentialPolicyTests.swift` out of `PackageAndCommandPolicyTests.swift` for package-manager auth/config, CLI credential-store, and cloud/container credential scanner policy contracts with no intended behavior change.
- Split `BaselineCommandPolicyTests.swift` out of `PackageAndCommandPolicyTests.swift` for lockfile/version-manager mutation, remote-script execution, language global package mutation, and GitHub CLI mutation contracts with no intended behavior change.
- Renamed the remaining `PackageAndCommandPolicyTests.swift` suite to `JavaScriptMetadataPolicyTests.swift` for JavaScript script, package-manager metadata, runtime hint, and version-check contracts with no intended behavior change.
- Split `HostPrivateDataPolicyTests.swift` out of `SecretFileDetectionTests.swift` for environment dump, clipboard, shell history, browser/mail data, and home SSH private-key policy contracts with no intended behavior change.
- Split `SecretFilePolicyTests.swift` out of `SecretFileDetectionTests.swift` for detected secret-bearing file avoidance, recursive-search review, and bulk-export policy contracts with no intended behavior change.
- Split `ProjectSymlinkSafetyTests.swift` out of `SecretFileDetectionTests.swift` for symlinked project metadata, workflow, SSH directory, package-auth directory, and previous-scan symlink delta contracts with no intended behavior change.
- Split `PackageAuthConfigPolicyTests.swift` out of `SecretFileDetectionTests.swift` for npm, Python, Ruby, Cargo, and Composer package-auth config non-emission contracts with no intended behavior change.
- Split `RepresentativeExampleTests.swift` out of `HabitatCoreTests.swift` for representative generated example drift checks and artifact metadata contracts with no intended behavior change.
- Split `AgentContextOutputContractTests.swift` out of `HabitatCoreTests.swift` for short-context overflow, prioritization, hidden Git guard summary, and line-budget contracts with no intended behavior change.
- Split `ScanExecutionInfrastructureTests.swift` out of `HabitatCoreTests.swift` for scan argument parsing, command-runner missing-tool behavior, bundled skill helper selection, missing-project guards, and missing-command continuation with no intended behavior change.
- Moved the remaining package-manager review routing contract out of `HabitatCoreTests.swift` and into `PolicyReasonCatalogTests.swift`, keeping catalog ownership checks in one suite with no intended behavior change.
- Renamed the remaining `HabitatCoreTests.swift` file to `CoreInfrastructureTests.swift`, matching the suite ownership after the test-boundary split with no intended behavior change.
- Restored three intended Swift Testing scenarios by marking pnpm selection, older scan-result decoding, and unrelated diagnostic filtering functions as executable tests.
- Added `TestCoverageContractTests.swift` to fail fast when scenario functions in test suites are missing Swift Testing `@Test` annotations.
- Added a `PolicyReasonCatalogTests` contract that fails if baseline Ask First or Forbidden policy catalogs duplicate rendered entries or overlap classifications.
- Added a `PolicyOutputContractTests` contract that verifies `scan_result.json` command-reason metadata mirrors generated Ask First and Forbidden command order.
- Added a `PolicyOutputContractTests` contract that verifies `scan_result.json` command-reason metadata stays one-to-one with generated Ask First and Forbidden commands.
- Added a `PolicyOutputContractTests` contract that verifies `scan_result.json` Review First reason metadata stays within Ask First command reasons.
- Moved the static baseline Ask First and Forbidden command lists into `PolicyReasonCatalog`, reducing scanner/catalog drift while preserving generated output behavior.
- Split the catalog-owned static baseline Ask First and Forbidden policy lists into `PolicyReasonCatalog+BaselinePolicy.swift` with no intended generated-output behavior change.
- Added Nenrin change record for the maintainability split and observation guidance for future decomposition slices.
- Updated documentation (`README.md`, `docs/roadmap.md`, `docs/current_status.md`, `docs/self_use.md`) to reflect completed decomposition and current codebase state.
- Extracted Git/GitHub command families and membership predicates into `PolicyReasonCatalog+Git.swift` with no intended generated-output behavior change.
- Extracted ephemeral package execution command families into `PolicyReasonCatalog+EphemeralPackageExecution.swift` with no intended generated-output behavior change.
- Extracted package-registry mutation command families into `PolicyReasonCatalog+PackageRegistry.swift` with no intended generated-output behavior change.
- Extracted CLI auth-session and credential-store command families into `PolicyReasonCatalog+CliAuth.swift` with no intended generated-output behavior change.
- Extracted package-manager credential/session and config command families into `PolicyReasonCatalog+PackageManagerCredential.swift` with no intended generated-output behavior change.
- Extracted cloud/container credential and auth-session command families into `PolicyReasonCatalog+CloudContainerCredential.swift` with no intended generated-output behavior change.
- Extracted credential/auth-session reason routing into `PolicyReasonCatalog+CredentialAuth.swift` with no intended generated-output behavior change.
- Extracted host-private data command families into `PolicyReasonCatalog+HostPrivate.swift` with no intended generated-output behavior change.
- Extracted Corepack package-manager activation command families into `PolicyReasonCatalog+PackageManagerActivation.swift` with no intended generated-output behavior change.
- Extracted SwiftPM dependency-resolution command families into `PolicyReasonCatalog+SwiftPM.swift` with no intended generated-output behavior change.
- Extracted JavaScript package-manager dependency-mutation command families into `PolicyReasonCatalog+JavaScriptPackageManager.swift` with no intended generated-output behavior change.
- Extracted Python pip/uv package-manager command families into `PolicyReasonCatalog+PythonPackageManager.swift` with no intended generated-output behavior change.
- Extracted Ruby Bundler package-manager command families into `PolicyReasonCatalog+RubyPackageManager.swift` with no intended generated-output behavior change.
- Extracted remote-script execution and global environment mutation command families into `PolicyReasonCatalog+HostEnvironment.swift` with no intended generated-output behavior change.
- Extracted Homebrew direct and Bundle Ask First command families into `PolicyReasonCatalog+Homebrew.swift` with no intended generated-output behavior change.
- Extracted Go and Cargo dependency-mutation command families into `PolicyReasonCatalog+GoCargo.swift` with no intended generated-output behavior change.
- Extracted CocoaPods, Carthage, and Xcodebuild command families into `PolicyReasonCatalog+ApplePackageManager.swift` with no intended generated-output behavior change.
- Extracted secret-bearing broad-search command families into `PolicyReasonCatalog+SecretSearch.swift` with no intended generated-output behavior change.
- Extracted workspace mutation command families into `PolicyReasonCatalog+WorkspaceMutation.swift` with no intended generated-output behavior change.
- Extracted SSH private-key command families into `PolicyReasonCatalog+SshPrivateKey.swift` with no intended generated-output behavior change.
- Extracted virtual-environment and version-manager Ask First command families into `PolicyReasonCatalog+ProjectEnvironment.swift` with no intended generated-output behavior change.
- Extracted selected package-manager review routing into `PolicyReasonCatalog+PackageManagerReview.swift` with no intended generated-output behavior change.
- Clarified that the first `v0.5` evidence slice should wrap secret-bearing path signals in a small `SecretBearingEvidence` value without changing `scan_result.json`, public `ReportWriter` API, generated Markdown, PolicyFinding, reason codes, or command ordering.
- Added the first local `v0.5` evidence boundary by wrapping secret-bearing path signals in `SecretBearingEvidence` and routing secret detection/report generation through it without intended generated-output behavior change.
- Restored cloud/container credential non-emission regression coverage by marking the existing secret-file detection scenario as an executable Swift Testing test.
- Hardened the behavior-evaluation fixture contract so all behavior evidence rejects local paths, prompt/secret/history field names, and common dummy token markers in one shared sanitization check.
- Split `BehaviorEvidenceSanitizationTests.swift` out of `BehaviorEvaluationTests.swift` for behavior-evidence schema and sanitization contracts with no intended behavior change.

## v0.4.0 Developer Preview - 2026-05-04

Policy Finding Foundation release.

### Changed

- Added a project-local Nenrin improvement observation ledger and connected it to the Habitat self-use development loop.
- Updated post-`v0.3.0` development guidance to keep automation focused on small self-use observation loops that feed policy, evidence, and documentation improvements before broad feature expansion.
- Re-scoped the post-`v0.3.0` roadmap so `v0.4` targets a thin Policy Finding Foundation, with broader evidence normalization and behavior feedback-loop work moved to later phases.
- Introduced a thin `PolicyFinding` policy-decision model and routed generated command-reason metadata through it while preserving the existing `scan_result.json` shape.
- Updated generated artifact metadata to report generator version `0.4.0`.
- Centralized JavaScript package-manager dependency-mutation command families used by generated Ask First policy and selected review ordering, preserving command lists while classifying `yarn up` as `dependency_mutation`.
- Centralized Corepack package-manager activation commands and annotated them with `package_manager_activation` instead of generic approval metadata.

## v0.3.0 Developer Preview - 2026-05-03

Agent Behavior Evaluation release.

### Added

- Added initial `docs/evaluation.md` guidance for the `v0.3` Agent Behavior Evaluation phase.
- Added a human-observed evaluation format with evidence policy, risk-aware verdict scale, planned cases, and observed cases.
- Added a clean synthetic SwiftPM behavior fixture comparing no Habitat context with Habitat context plus policy review.

### Changed

- Updated development automation guidance to focus on behavior-evaluation slices after the `v0.2.0` release.
- Added checksum verification to the README release-install flow.
- Expanded the Habitat self-use behavior fixture with verdict and risk-aware behavior metadata.
- Clarified that post-`v0.3` roadmap items may be re-ranked from behavior evidence, with high-confidence scenarios preferred over broad coverage.
- Updated generated artifact metadata to report generator version `0.3.0`.

## v0.2.0 Developer Preview - 2026-05-02

Agent Reading Contract release.

### Added

- Added report-relative artifact path metadata to `scan_result.json` so agents and tools can resolve generated Markdown files from a report directory.
- Added generated artifact read-role, read-trigger, read-order, entry-section, entry-line, section-heading line, line-count, character-count, and line-limit metadata for `agent_context.md`, `command_policy.md`, and `environment_report.md`.
- Added command policy reason metadata, command counts, and Review First command metadata so agents can inspect approval reasons without parsing all Markdown.
- Added a bundled `skills/hazakura-habitat` entrypoint for AI agents to run Habitat as a preflight before substantial work.

### Changed

- Stabilized `agent_context.md` around the fixed `Use`, `Prefer`, `Ask First`, `Do Not`, and `Notes` structure.
- Kept `agent_context.md` focused on short command-changing guidance with a 120-line hard budget and overflow guidance that points to the full policy or audit report.
- Reworked `command_policy.md` with a compact `Policy Index`, a high-priority `Review First` section, reason codes, and a reason-code legend before long command lists.
- Kept generated policy advisory-only: Habitat still does not execute, approve, block, sandbox, or enforce commands.
- Clarified that `scan_result.json` remains preview metadata in the `v0.x` series; its purpose is stable, but individual fields may change before `v1.0`.

### Verified

- Local `swift test` passed with 182 tests.
- Self-scan output kept `agent_context.md` under the 120-line limit with no warnings during release preparation.

## v0.1.1 Developer Preview - 2026-05-01

Post-release expectation-setting patch.

### Changed

- Clarified advisory-only language in generated `command_policy.md`.
- Updated README first-time user flow, release install steps, requirements, and exit-code notes.
- Added representative examples for SwiftPM, Node/pnpm lockfile conflict, Python uv missing-tool, and secret-bearing file scenarios.
- Added `CONTRIBUTING.md` and GitHub issue templates.
- Fixed public-preview time-axis wording in docs after the repository became public.

## v0.1.0 Developer Preview - 2026-05-01

Initial public developer preview.

### Included

- SwiftPM CLI: `habitat-scan`.
- Read-only project scan command:
  - `habitat-scan scan --project <path> --output <path>`
- AI-facing artifacts:
  - `scan_result.json`
  - `agent_context.md`
  - `command_policy.md`
  - `environment_report.md`
- `schemaVersion` and `generatorVersion` metadata in `scan_result.json`.
- Project signal detection for SwiftPM/Xcode, Node package managers, Python pip/uv, Ruby Bundler, Go, Cargo, CocoaPods, Carthage, Brewfile, and secret-bearing file presence.
- Conservative command policy for preferred commands, Ask First commands, and Forbidden commands.
- Previous-scan comparison for command-changing deltas.
- Secret-value non-emission tests and safety hardening around secret-bearing files, auth config, shell history, clipboard, browser/mail data, cloud/container credentials, and destructive commands.
- Release artifact build with `SHA256SUMS`.
- MIT License.

### Preview Limitations

- macOS-first.
- Advisory only; Habitat does not execute, approve, or block commands.
- JSON fields may evolve during `v0.x`.
- Markdown output is optimized for AI-agent consumption, not stable machine parsing.
- No GUI, MCP server, sandbox, automatic repair, or broad environment inventory.
