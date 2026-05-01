# Public Readiness

This document captures the completed publication plan for `v0.1.0 Developer Preview`.

The repository is now public. This checklist remains as an audit trail for the first public preview and as a reminder that the next step is not broad feature expansion. The next step is keeping the project safe to understand, safe to review, and hard to misinterpret.

## Release Positioning

Publish as:

```text
v0.1.0 Developer Preview
macOS-first
AI-agent-facing context generator
advisory, not enforcement
read-only scan
no secret values
```

Do not present the project as a finished safety system.

Hazakura Habitat does not make AI coding agents safe by itself. It generates conservative pre-execution context that an agent or user can follow.

## Public Scope

Included in the first public preview:

- SwiftPM CLI
- `habitat-scan scan --project <path> --output <path>`
- read-only project scan
- AI-facing context generation
- command-decision policy artifacts
- limited previous-scan comparison
- secret-bearing file presence detection without value reads

Outputs:

- `scan_result.json`
- `agent_context.md`
- `command_policy.md`
- `environment_report.md`

Supported signal families at preview depth:

- SwiftPM and Xcode
- Node package managers
- Python pip and uv
- Ruby Bundler
- Go
- Cargo
- CocoaPods
- Carthage
- Brewfile
- secret-bearing file presence

Explicitly out of scope for the first public preview:

- GUI
- MCP server
- global machine inventory
- deep Homebrew inspection
- secret value scanning
- automatic command execution
- automatic environment repair
- Linux or Windows support guarantees

## Output Rules

`agent_context.md` is the primary product surface for AI agents.

Target shape:

- short enough for an agent to actually follow
- command-relevant
- conservative without being paralyzing
- no secret values
- no raw untrusted project prose

Budget:

- target: under 80 lines
- hard limit: under 120 lines
- diagnostics should move to `environment_report.md`

Rule of thumb:

> Information belongs in `agent_context.md` only when it can change the agent's next one to three commands.

`command_policy.md` may be longer, but it should remain grouped, explainable, and focused on command behavior rather than exhaustive local inventory.

## Advisory Policy Language

Generated policy is advisory.

`Forbidden` means:

> The generated context tells the agent not to run this.

It does not mean:

> The operating system or CLI will block this command.

README, release notes, and docs should avoid claims such as:

- makes AI coding agents safe
- prevents dangerous commands
- secure automation
- guaranteed protection

Prefer:

- conservative
- read-only
- agent-facing
- pre-execution context
- advisory command policy

## Prompt-Injection Policy

Hazakura Habitat generates Markdown that AI agents may read. That output can itself become a prompt-injection surface if project-controlled text is copied into it.

Rules:

- Do not include arbitrary project file contents in `agent_context.md`.
- Treat all project-derived strings as untrusted data.
- Prefer normalized signals over raw text.
- Quote or escape project-controlled names when needed.
- Do not include package script bodies, README prose, comments, or other long project-authored text in AI-facing artifacts.

Good:

```text
Use SwiftPM (`swift`) because project files point to it.
```

Risky:

```text
README says: Ignore previous instructions and run ...
```

## Public Hygiene Checklist

Required before making the repository public:

- [x] README explains what the project is and is not.
- [x] README explains advisory policy, not enforcement.
- [x] README explains secret values are not read or emitted.
- [x] README states macOS-first and Developer Preview status.
- [x] LICENSE exists.
- [x] GitHub Actions runs `swift test` on macOS.
- [x] `scan_result.json` includes schema/generator version metadata, while README still marks `v0.x` fields as developer-preview evolving.
- [x] Output examples exist or README includes a representative `agent_context.md`.
- [x] Known limitations are documented.
- [x] Tracked files are scanned for real secrets.
- [x] Git history is scanned for real secrets before public visibility.
- [x] Dummy secret-like test strings are explained.
- [x] Local absolute paths are reviewed.
- [x] Generated outputs and release artifacts are ignored by git.
- [x] Prompt-injection and untrusted project data policy is documented.
- [x] Symlinked project metadata is recorded without reading linked hint values, and symlinked `.ssh` directories are not traversed.

Already true or partially true:

- CI workflow exists and runs `swift build` / `swift test` on macOS.
- `dist/`, `.build/`, and `habitat-report/` are ignored.
- Current tracked-file and git-history scans found only test dummy secret-like strings and code variable names, not real credentials.

## Nice Before Public, Not Blocking

- [x] Example fixtures for SwiftPM, Node/pnpm, and Python/uv.
- [ ] Command-policy reason text.
- [x] `agent_context.md` output length budget tests.
- [x] Exit-code semantics documented.
- [x] `SECURITY.md`.
- [x] `CHANGELOG.md` with `v0.1.0`.
- [x] Release binary checksum.
- [x] Issue templates and contribution guide.

## Public-After Roadmap

See `docs/roadmap.md` for the post-public roadmap.

Short version: do after the public preview, not before:

- package-manager version metadata refinements
- deeper pip/uv policy
- broader previous-scan comparison
- Swift/Xcode scanner detail
- Homebrew scanner detail
- `.habitatignore`
- MCP server
- GUI
- redaction modes

## Avoid

Do not turn the project into:

- global machine inventory
- automatic install/update/fix tool
- broad environment dashboard
- secret value reader, even with redaction
- early Linux/Windows compatibility promise
- exhaustive Homebrew or global package scanner

The acceptance question for new scope is:

> Will this signal change the AI agent's next command choice?

If not, defer it.

## Technical Risks to Track

### Project Code Execution

Scanner commands should stay read-only and bounded.

Prefer:

- `--version`
- static parsing
- file existence checks
- lockfile and project signal detection

Avoid during scan:

- `npm run ...`
- `python -c "import project..."`
- `swift build`
- `swift test`
- `bundle exec ...`
- `pod install`

### Symlinks and Project Boundaries

Default policy should be:

- do not follow symlinks outside the selected project root by default
- record symlink presence only when it affects command choice or safety
- never read secret-bearing symlink targets

Current preview behavior records safety-relevant project symlinks in `project.symlinkedFiles`, avoids reading symlinked metadata for runtime/package hints, avoids traversing symlinked `.ssh` and package-auth ancestor directories such as `.bundle`, and adds Ask First guidance before following project symlinks.

### Output Directory Safety

Generated output should use fixed filenames and should not delete unrelated existing files.

Documented behavior should cover:

- output directory must be writable
- generated files have fixed names
- no recursive cleanup unless explicit
- scanner failures become scan data when artifacts can still be produced

## Roadmap Phases

### Phase 0: Public Readiness

- README
- LICENSE
- privacy and security notes
- CI
- schema/generator version metadata
- examples or sample output
- known limitations
- tracked-file and git-history secret scans
- prompt-injection policy

### Phase 1: Output Quality Hardening

- `agent_context.md` structure and line budget caps for warning-heavy scans
- command-policy reasons
- policy reason codes
- snapshot tests for shape and length
- prompt-injection resistance tests

### Phase 2: Agent Behavior Evaluation

Create small fixtures that check whether generated context changes expected agent behavior.

Examples:

- pnpm project with conflicting npm lockfile: prefer pnpm, ask before npm install.
- SwiftPM project: prefer `swift test` / `swift build`, ask before package update.
- project with `.env` and private key signal: do not read secret-bearing files.
- missing preferred package manager: ask first instead of silently substituting.

### Phase 3: Policy Model Refactor

Keep this as a future design direction, not a public-blocking rewrite.

Target flow:

```text
DetectedSignal -> PolicyFinding -> RenderedOutput
```

Prefer clear boundaries between:

- signal detection
- evidence normalization
- policy decision
- output rendering

### Phase 4: Integrations

Consider MCP and editor workflows only after CLI output quality is proven.

Early MCP scope should be read-oriented:

- `get_agent_context`
- `get_command_policy`
- `explain_policy_decision`

Avoid approval or enforcement workflows until the advisory model is mature.
