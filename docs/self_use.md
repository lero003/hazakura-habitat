# Self-Use Loop

Hazakura Habitat should be used by Codex before substantial work on Hazakura Habitat itself.

This is not a marketing demo. It is a product feedback loop: if the generated context does not help an AI coding agent choose a better next command in this repository, the output contract needs work.

Do not treat the self-scan as a requirement for every small edit. It should earn its cost by catching current repository facts, risky command boundaries, or instruction drift that an agent would not get from `AGENTS.md`, roadmap, or development docs alone. When those docs are complete, current, and enough for a low-risk task, not running Habitat is a valid outcome.

Use the scan before work that can change the agent's command choice or safety boundary:

- yes: new or unfamiliar repository work, dependency or package-manager changes, release or Git/GitHub mutation, secret-adjacent inspection, generated-output contract changes, automation prompt changes, or project guidance changes
- usually no: small copy edits, focused test expectation updates, single-file refactors that do not touch scanner behavior, or follow-up verification where the current report and docs already answer the command question
- decide from risk: bundled skill edits, new cron or automation setup, and package metadata edits should scan when they affect future agent behavior, command policy, credentials, release flow, or dependency choice

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

In restricted automation sandboxes, plain SwiftPM commands can fail before project code runs because compiler caches or SwiftPM's own sandbox wrapper are not writable or available. If that happens, keep the same SwiftPM verification decision and retry with a writable process-local cache plus SwiftPM's non-sandboxed flag, for example:

```bash
CLANG_MODULE_CACHE_PATH=<writable-cache-dir> swift build --disable-sandbox
CLANG_MODULE_CACHE_PATH=<writable-cache-dir> swift test --disable-sandbox
```

Do not turn this into dependency resolution, package installation, global cache cleanup, or release/GitHub mutation.

When the skill is available, the equivalent helper is:

```bash
skills/hazakura-habitat/scripts/run_habitat_scan.sh .
```

Read the generated files before continuing:

- `habitat-report/agent_context.md` for the short working context.
- `habitat-report/command_policy.md` before dependency, Git/GitHub, secret-adjacent, archive, copy, sync, or environment-sensitive commands.
- `habitat-report/environment_report.md` only when audit or debug detail is needed.

Do not commit `habitat-report/`. Convert useful findings into docs, fixtures, tests, examples, or roadmap items.

Treat `habitat-report/` as a working snapshot. Regenerate it when repository facts or project guidance changed, when the previous report came from a different public baseline, or when a risky command decision depends on current package-manager, secret, Git/GitHub, release, or generated-output state. If an old report is no longer the active context, delete it locally or ignore it; do not make cleanup its own product feature until stale reports cause a measured agent mistake.

Use `nenrin/` as the companion observation ledger for changes to the self-use environment itself. When self-use changes Habitat docs, bundled skills, roadmap, release guidance, QA criteria, or automation prompts, create or update a Nenrin change record. After a later related task, add an observation describing whether the change affected the agent's next command or cleanup decision.

When evaluating self-use output, discount guidance that merely repeats existing instructions. Stronger evidence is a repository fact that changes or constrains the next command: a conflicting lockfile, a missing preferred tool, a secret-bearing path that changes search shape, a generated-output mismatch, or a release/CI/GitHub risk that requires policy review. Also record when a strong `AGENTS.md` made Habitat unnecessary; that is not a product failure unless a later command mistake shows the skipped preflight mattered.

## Current Self-Scan Snapshot

Snapshot date: 2026-05-06 (post-maintainability split; `SecretFileDetector` extraction, test-suite decomposition, and no-output-change catalog boundaries preserved generated output, so policy values are unchanged from 2026-05-04).

Observed output from scanning this repository:

- Package manager: SwiftPM.
- Preferred commands: `swift test`, `swift build`.
- `agent_context.md`: 35 lines in `scan_result.json` artifact metadata.
- `command_policy.md`: 800 lines in `scan_result.json` artifact metadata.
- `environment_report.md`: 73 lines in `scan_result.json` artifact metadata.
- Ask First commands: 262.
- Forbidden commands: 489.
- `scan_result.json` `policy.commandCounts`: 2 preferred, 262 Ask First, 6 Review First, 489 Forbidden, 751 with reasons.
- `scan_result.json` `policy.reasonCodes`: 15 reason families, including `package_manager_activation`, `remote_repository_action`, `ephemeral_package_execution`, and `package_registry_mutation`.
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
- Secret-bearing file guidance is indexed and rendered before the long `Allowed`/`Ask First`/`Forbidden` command lists, so broad `rg`, `grep -R`, or `git grep` searches are reviewed for exclusions before an agent scans hundreds of policy lines; `command_policy.md` now gives a concrete `git grep` pathspec-exclusion shape for tracked-file searches.
- Full `Ask First` and `Forbidden` entries now carry reason code annotations, so long policy lists remain explainable at the point of use.
- Auth/session and package-manager config forbids now use the `secret_or_credential_access` reason family, so credential-related refusals do not collapse into generic unsafe-command metadata.
- CLI auth-session and credential-store commands now have their own `PolicyReasonCatalog+CliAuth.swift` boundary, so future `gh auth`, Git credential-helper, or macOS `security` additions update one family without changing generated output shape.
- Package-manager credential/session and config commands now have their own `PolicyReasonCatalog+PackageManagerCredential.swift` boundary, so future pip/npm/pnpm/yarn/Bundler/Cargo/CocoaPods credential additions update one family without changing generated output shape.
- Cloud/container credential and auth-session commands now have their own `PolicyReasonCatalog+CloudContainerCredential.swift` boundary, so future AWS, gcloud, Docker, or Kubernetes credential additions update one family without changing generated output shape.
- Host-private data commands now have their own `PolicyReasonCatalog+HostPrivate.swift` boundary, so future environment dump, clipboard, shell-history, browser-profile, or local-mail additions update one family without changing generated output shape.
- Corepack package-manager activation commands now have their own `PolicyReasonCatalog+PackageManagerActivation.swift` boundary, so future shim, package-manager version, or project-metadata activation additions update one family without changing generated output shape.
- SwiftPM dependency-resolution commands now have their own `PolicyReasonCatalog+SwiftPM.swift` boundary, so future `swift package update` / `swift package resolve` policy changes update one family without changing generated output shape.
- JavaScript package-manager dependency-mutation commands now have their own `PolicyReasonCatalog+JavaScriptPackageManager.swift` boundary, so future npm, pnpm, yarn, or bun install/update/remove edits update one family without changing generated output shape.
- Python pip/uv package-manager Ask First commands now have their own `PolicyReasonCatalog+PythonPackageManager.swift` boundary, so future pip install/fetch/cache or uv mutation edits update one family without changing generated output shape.
- Ruby Bundler package-manager Ask First commands now have their own `PolicyReasonCatalog+RubyPackageManager.swift` boundary, so future `bundle install`, `bundle add`, `bundle update`, `bundle lock`, or `bundle remove` edits update one family without changing generated output shape.
- Remote-script execution and global environment mutation commands now have their own `PolicyReasonCatalog+HostEnvironment.swift` boundary, so future `curl | sh`, Homebrew host-state, global package install, pipx, uv tool, gem, Go, or Cargo host-mutation edits update one family without changing generated output shape.
- Homebrew direct Ask First and Bundle review commands now have their own `PolicyReasonCatalog+Homebrew.swift` boundary, so future `brew install`, `brew update`, `brew tap`, or `brew bundle` edits update one family without changing generated output shape.
- Go and Cargo dependency-mutation commands now have their own `PolicyReasonCatalog+GoCargo.swift` boundary, so future `go get`, `go mod tidy`, `cargo add`, `cargo update`, or `cargo remove` edits update one family without changing generated output shape.
- CocoaPods, Carthage, and Xcodebuild commands now have their own `PolicyReasonCatalog+ApplePackageManager.swift` boundary, so future `pod install`, `carthage update`, or Xcode project-mutation edits update one family without changing generated output shape.
- Secret-bearing broad-search commands now have their own `PolicyReasonCatalog+SecretSearch.swift` boundary, so future `rg`, `grep -R`, `find ... grep`, or `git grep` search-shape edits update one family without changing generated output shape.
- Workspace mutation commands now have their own `PolicyReasonCatalog+WorkspaceMutation.swift` boundary, so future permission, rewrite, copy/move/sync/archive, or destructive cleanup edits update one family without changing generated output shape.
- Secret-bearing path signals now have a small `SecretBearingEvidence` boundary consumed by secret detection and report generation, so future evidence-alignment work can build from filename-only signals without changing generated output shape or storing raw secret values.
- When secret-bearing files are detected, `agent_context.md` now gives a concrete broad-search starting shape with exclusion globs, so agents can reshape `rg`/`grep -R`/`git grep` instead of treating all project search as off limits.
- `command_policy.md` now distinguishes no-secret read-only search from secret-bearing projects: ordinary `rg <pattern>` remains allowed in normal repositories, while secret-bearing repositories steer agents toward targeted inspection and exclusion-aware search.
- The `agent_context.md` Ask First overflow line now names hidden reason codes in stable catalog order, and when Git/GitHub mutation guards are already summarized it names the other hidden reason families first, so Codex can see remaining dependency, tool, or approval risks before opening the full policy.
- Ephemeral package execution commands now carry their own `ephemeral_package_execution` reason code, so `npx`/`dlx`/`uvx`/`pipx run` guards no longer collapse into generic approval metadata; the command family now has its own `PolicyReasonCatalog+EphemeralPackageExecution.swift` boundary.
- Package publication and registry metadata mutation commands now carry `package_registry_mutation`, so the long policy explains external package-state risk instead of collapsing publish, yank, owner, or dist-tag commands into generic dependency or approval metadata.
- Package-registry mutation commands now have their own `PolicyReasonCatalog+PackageRegistry.swift` boundary, so future publish, owner, dist-tag, yank, or trunk additions update one family without changing generated output shape.
- Corepack package-manager activation commands now carry `package_manager_activation`, so `corepack enable`, `corepack prepare`, `corepack install`, `corepack use`, and related commands explain shim/version/project-metadata risk instead of generic approval metadata.
- Remote GitHub commands now carry `remote_repository_action` when they act on PRs, issues, CI, releases, secrets, variables, or remote API content, so long-policy review separates remote repository risk from local Git workspace mutation.
- `scan_result.json` now records generated Markdown artifact roles, report-relative paths, agent reading role, read trigger, read order, entry section, entry line, section heading line index, line counts, character counts, the `agent_context.md` line limit, and whether line-limited outputs are within budget, so agents can open the right report-local file, identify the short working context first, and jump to `Review First`, `Ask First`, `Forbidden`, or diagnostics when continuing into longer reports without parsing every report.
- `agent_context.md` now states that it is the short working context and keeps full approval detail in `command_policy.md`, so agents can stop after the first artifact unless a risky command needs policy review.
- `scan_result.json` now records `policy.commandCounts`, so agents can see policy size, short approval-checklist size, and reason coverage before deciding whether to inspect the full `command_policy.md`.
- `scan_result.json` now records `policy.reviewFirstCommandReasons`, so agents and tools can read the highest-priority approval checklist with reasons without parsing `command_policy.md`.
- The bundled helper must use the current source checkout for self-scans instead of silently falling back to `dist/`, otherwise a stale local release artifact can hide new output-contract sections.
- In restricted automation sandboxes, the useful command decision is still SwiftPM verification; a writable process-local compiler cache and `--disable-sandbox` can unblock `swift build` or `swift test` without changing dependency resolution or global caches.

## v0.2 Findings

The self-scan supports the v0.2 Agent Reading Contract focus.

Keep:

- `agent_context.md` short and command-changing.
- Missing-tool diagnostics available in audit or JSON data without making the short context noisy.
- Advisory-only wording in generated policy output.

Improve:

- Make `command_policy.md` easier to navigate when it is hundreds of lines long.
- Separate project-relevant policy from broad baseline safety policy more clearly.
- Continue reason-code groundwork so large policy sections are explainable and eventually groupable.
- Keep Git/GitHub mutation guards visible before broad baseline package-manager guards when reviewing the full command policy.
- Evaluate search-command shape separately for projects with and without detected secret-bearing files: unrestricted `rg` is reasonable in ordinary repos, but secret-bearing repos should steer agents toward exclusion globs such as `--glob '!.env'`, policy review, or Ask First before recursive search. Do not overcorrect by banning useful search outright.
- Continue output shape metadata and tests that catch growth before it becomes normal.
- Treat `agentUse`, `readTrigger`, `readOrder`, `entrySection`, section line metadata, line counts, character counts, and command counts as preview reading hints during `v0.x`, not a fully stable schema promise.
- Capture future self-use evidence as sanitized traces, not raw prompts or local-path-heavy logs.
- Update representative examples whenever generated output wording or structure changes.

## Acceptance Question

After reading `agent_context.md`, would Codex choose a better next command?

If `command_policy.md` is needed, can Codex find the relevant rule quickly enough to act conservatively?
