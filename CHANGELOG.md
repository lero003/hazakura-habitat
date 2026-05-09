# Changelog

## Unreleased

### Changed

- Recorded post-`v0.5.0` review guidance in automation-facing docs: no rollback, hotfix, or release-note edit is needed for `v0.5.0`, and future instruction-alignment work should stay in narrow `v0.5.x` / `v0.6` slices.
- Clarified future release workflow guidance so release artifact builds are verified before public version tags when practical, while published releases and tags remain immutable.
- Updated the bundled `hazakura-habitat` skill so its helper retries source-checkout builds with a writable module cache and `--disable-sandbox`, and so the skill preserves the post-`v0.5` / `v0.6` observation feedback loop.
- Added a `PolicyOutputContractTests` contract that verifies `scan_result.json` reason-code legend metadata covers every serialized command-reason and Review First reason code.
- Added a `PolicyOutputContractTests` contract that verifies serialized command-reason text matches the matching `policy.reasonCodes` legend text.
- Added a `PolicyOutputContractTests` contract that verifies `command_policy.md` `Reason Codes` lines stay in sync with serialized `policy.reasonCodes` metadata.
- Added a `PolicyOutputContractTests` contract that keeps generic Ask First and Forbidden fallback reason codes present in `policy.reasonCodes`.
- Added a `PolicyOutputContractTests` budget contract that keeps full `command_policy.md` approval detail from growing past the preview readability threshold without an explicit test update.
- Added a `PolicyOutputContractTests` contract that verifies `command_policy.md` `Review First` lines stay in sync with serialized `policy.reviewFirstCommandReasons` metadata.
- Added a `PolicyOutputContractTests` contract that verifies `command_policy.md` `Policy Index` counts stay in sync with generated policy metadata and section contents.
- Added a `PolicyOutputContractTests` contract that verifies `command_policy.md` `Policy Index` ordering follows the rendered policy section order.
- Added a `PolicyOutputContractTests` contract that verifies `command_policy.md` `Policy Index` omits absent conditional sections instead of pointing agents at empty headings.
- Added a `PolicyOutputContractTests` contract that verifies `command_policy.md` `Ask First` and `Forbidden` reason-code annotations stay in sync with serialized `policy.commandReasons` metadata.
- Added a `PolicyOutputContractTests` contract that verifies `command_policy.md` `Ask First` ordering keeps secret-bearing search, missing-tool, selected package-manager, lockfile, and Git risks in priority order.
- Added an `AgentContextOutputContractTests` contract that keeps hidden Ask First overflow summaries bounded to the first three structured reason codes plus `more`.
- Changed `agent_context.md` Ask First overflow counts so Git/GitHub guards summarized by the dedicated mutation reminder are not counted again in the additional hidden-command line.
- Added an `AgentContextOutputContractTests` contract that keeps summarized Git/GitHub mutation guards discoverable as concrete `Review First` entries in `command_policy.md`.
- Added a `PolicyReasonCatalogTests` contract that keeps generic dependency-mutation fallback behind specific command-family rules.
- Added a `PolicyReasonCatalogTests` contract that keeps dependency-shaped package registry, Corepack activation, and ephemeral execution commands ahead of generic dependency-mutation fallback.
- Added a `PolicyReasonCatalogTests` contract that keeps selected package-manager Review First routing limited to non-duplicated baseline Ask First commands, with SwiftPM dependency-resolution commands pinned as the explicit selected-workflow exception.
- Added a `PolicyReasonCatalogTests` contract that keeps specific Forbidden reason families ahead of the generic unsafe-command fallback.
- Added a pre-commit configuration warning in `agent_context.md` and `PreCommitPolicyTests` coverage so agents check `git status` after commit hooks may mutate the workspace.
- Added a `PolicyReasonCatalogTests` contract that keeps GitHub CLI local workspace commands under `git_mutation` while remote GitHub actions stay under `remote_repository_action`.
- Changed workspace mutation reason-code routing so `rm`, `rm -r`, `rm -rf`, and `xargs rm` use `user_approval_required` instead of falling through to dependency-mutation reasoning.
- Added CI workflow presence to scan data and `agent_context.md` uncertainty when CI exists but repository facts do not identify a local verification command.
- Changed documented validation-command alignment so multiple instruction files that point to different validation workflows emit bounded `Open uncertainty` instead of silently trusting the first claim.
- Changed documented validation-command extraction so negated, obsolete, or example-only command mentions are not recorded as positive validation claims.
- Changed documented validation-command alignment so a documented workflow with no repository-supported workflow emits bounded `Open uncertainty` instead of a confident mismatch warning.
- Changed documented Xcode validation alignment so `xcodebuild test` claims are constrained to `xcodebuild -list` scheme discovery before following the documented test command.
- Documented a cross-project observation boundary for using another local project's `habitat-report/` as self-use input without turning Habitat into a planner or a second workstream for that project.

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
