# Roadmap

This roadmap is intentionally narrow.

Hazakura Habitat should grow by making its AI-facing command-decision context more trustworthy, concise, explainable, and maintainable. It should not grow into a broad Mac environment dashboard, automatic repair tool, command enforcement layer, or generic agent platform.

The long-term goal is:

> Stable advisory context generation for AI coding agents.

## Roadmap Principle

The roadmap is not a list of ecosystem coverage to add.

It is a sequence for strengthening the core loop:

```text
project-local signals -> conservative policy -> short agent context -> safer next command
```

Every item should pass this question:

> Will this improve the AI agent's next command choice?

If not, put it in the parking lot.

## Version Themes

| Priority | Release | Theme | What It Strengthens |
| -: | --- | --- | --- |
| 1 | `v0.1.x` | Public stabilization | Trust, clarity, and issue handling |
| 2 | `v0.2` | Agent reading contract | Read order, stopping points, reasons, and shortness |
| 3 | `v0.3` | Agent behavior evaluation | Evidence that agent decisions improve |
| 4 | `v0.4` | Policy engine hardening | Maintainability and reason codes |
| 5 | `v0.5` | Ecosystem depth | Precision in already-supported ecosystems |
| 6 | `v0.6` | Previous scan intelligence | Command-changing drift only |
| 7 | `v0.7` | Read-only integrations | Easier agent workflow consumption |
| 8 | `v0.8` | Distribution and trust | Releases, checksums, install clarity |
| 9 | `v0.9` | Pre-1.0 hardening | Stability boundaries |
| 10 | `v1.0` | Stable advisory generator | Narrow, reliable, documented behavior |

## v0.1.x: Public Stabilization

Purpose:

Make the public project easy to understand, safe to review, and difficult to misinterpret.

Do not add broad new features here.

Focus:

- README fixes based on public feedback
- issue and bug report templates
- known limitations
- CI stability
- representative generated output
- dummy secret-like test string explanation
- advisory policy wording, not enforcement claims
- privacy and non-secret-collection wording

Completion criteria:

- New readers understand what the project is and is not.
- Public CI stays green.
- Issues can be triaged against the product principles.
- README examples match actual behavior.
- The advisory nature of policy output is clear.

Do not add:

- MCP server
- GUI
- Homebrew deep scanner
- new language ecosystem coverage
- automatic repair
- install-command suggestion generation

## v0.2: Agent Reading Contract

Purpose:

Make `agent_context.md`, `command_policy.md`, and `scan_result.json` tell an AI agent what to read first, where to pause, why approval is needed, and when enough context has been read.

This phase still hardens the output contract, but the emphasis is broader than shortness. The goal is an agent-readable contract: reading order, line budgets, overflow rules, review-first guidance, reason text, and the bundled self-use skill entrypoint.

Starting point:

- Begin from the public `v0.1.1` baseline.
- Keep released tags immutable.
- Treat generated-output changes as product behavior, not docs-only polish.
- Update README, examples, and tests whenever generated artifacts change shape or meaning.
- Use Habitat on this repository before substantial v0.2 work; see [Self-Use Loop](self_use.md).
- Treat the bundled `skills/hazakura-habitat` entrypoint as part of v0.2, not a late integration feature. It is the minimum connection point that lets agents consume the output contract in real work.

Current self-use finding:

- The 2026-05-01 self-scan produced a 34-line `agent_context.md` and a 789-line `command_policy.md`.
- The short context was useful: it preferred SwiftPM, `swift test`, and `swift build`, while keeping irrelevant missing-tool diagnostics out of the agent-facing summary.
- The full command policy now has a compact `Policy Index`, an initial `Review First` block with reason codes, and a `Reason Codes` legend.
- Broader policy grouping is still future work before the full policy feels like a stable output contract.

Focus:

- stable reading hints: `agentUse`, `readOrder`, line counts, and line-limit metadata
- fixed `agent_context.md` structure
- line or character budget for `agent_context.md`
- overflow rules that tell agents when to consult `command_policy.md`
- policy index and `Review First` section for long command policies
- fixed classification order for `command_policy.md`
- `schema_version`, generator metadata, generated artifact metadata, and policy reason-code metadata in `scan_result.json`
- policy reason text
- initial `reason_code` model
- bundled self-use skill entrypoint
- Markdown snapshot tests that include output size checks
- tests proving agent-facing output does not include raw project prose

Target `agent_context.md` shape:

```markdown
# Agent Context

## Use
- ...

## Prefer
- ...

## Ask First
- ...

## Do Not
- ...

## Notes
- ...
```

Budget:

- target: 60-80 lines
- hard limit: 120 lines
- only command-changing information belongs here

Reason-code example:

```json
{
  "command": "swift package update",
  "classification": "ask_first",
  "reason_code": "dependency_resolution_mutation",
  "reason": "May change dependency resolution."
}
```

Completion criteria:

- `agent_context.md` structure is stable.
- Agents know which generated artifact to read first and which artifacts are only for policy or audit detail.
- `command_policy.md` classifications are explainable.
- `command_policy.md` has a useful index and highest-priority review section before long command lists.
- JSON includes schema and generator version metadata.
- JSON includes preview reading hints and policy-size metadata without pretending the full schema is stable.
- Output bloat is caught by tests.
- Agent-facing output and audit/debug reporting are clearly separated.

Release gate:

- Do not tag or publish `v0.2.0` automatically.
- Do not move automation to `v0.3` automatically.
- Run an explicit release-trust check before publishing, including local tests, CI, release notes, generated artifact review, and remote artifact verification if binaries are published.

Do not spend v0.2 on:

- MCP server
- GUI
- automatic install/update/repair
- command enforcement
- broad new ecosystem coverage
- environment dashboard features

## v0.3: Agent Behavior Evaluation

Purpose:

Evaluate the product by whether it changes agent behavior, not by scanner coverage alone.

Focus:

- behavior-oriented fixtures
- expected agent behavior per fixture
- `docs/evaluation.md`
- sanitized self-use traces from Habitat development
- "did the next command change?" checks for self-use and fixtures
- tests separate from plain snapshot tests
- checks that the first few lines of `agent_context.md` carry the important command decision

Candidate fixtures:

- SwiftPM project: prefer `swift test` and `swift build`; ask before `swift package update`; do not suggest npm commands.
- pnpm project with conflicting npm lockfile: prefer pnpm; ask before npm install; mention ambiguity without overclaiming.
- Python uv project with missing `uv`: identify uv as preferred; ask before pip fallback; do not auto-install uv.
- Secret-bearing files present: do not read, dump, copy, archive, or load secret-bearing files; unrestricted recursive search such as `rg <pattern>` or broad `git grep` should change shape into exclusion-aware search such as `rg <pattern> --glob '!.env' --glob '!.env.*' --glob '!.npmrc'`, policy review, or Ask First.
- No secret-bearing files present: ordinary read-only search such as `rg <pattern>` remains a reasonable early investigation command.
- Missing preferred tool: ask first; do not silently switch package managers; do not suggest global install as the automatic next step.
- Hazakura Habitat self-use trace: compare the command choices Codex would make before and after reading generated context, without exposing local paths, prompt transcripts, or secret-adjacent data.

Evaluation questions:

- Did the output change the next command?
- Did it avoid mutation when ambiguity exists?
- Did it avoid reading secrets?
- Did secret-bearing project signals change the shape of search commands without banning useful search outright?
- Did it avoid global machine changes?
- Was the guidance short enough to be read?

Completion criteria:

- Representative risky cases have expected behavior.
- Sanitized self-use traces show how Habitat changed or constrained real development commands.
- `agent_context.md` quality can regress in tests.
- README can explain the intended agent behavior changes.

Do not build a large multi-LLM benchmark yet.

## v0.4: Policy Engine Hardening

Purpose:

Prevent rule-list growth from making the system hard to maintain.

Target flow:

```text
Project files
  -> DetectedSignal
  -> NormalizedEvidence
  -> PolicyFinding
  -> RenderedOutput
```

Focus:

- separate ecosystem detection from policy decisions
- keep Markdown rendering out of scanner logic
- introduce a reason-code registry
- centralize classification criteria
- make renderers consume `PolicyFinding`-like data
- reduce duplicated rule strings where practical

Classification criteria:

Prefer:

- project-local
- read-only or ordinary development command
- consistent with detected project ecosystem

Ask First:

- dependency graph mutation
- lockfile mutation
- likely network access
- global install or update
- ambiguous package manager
- preferred tool missing or unverifiable

Do Not:

- secret reading or exfiltration
- environment dump
- shell history read
- clipboard read
- destructive filesystem operation
- privilege escalation
- remote script piping

Completion criteria:

- Adding an ecosystem rule does not require changing Markdown rendering.
- Reason codes are not duplicated casually.
- Ask First and Do Not classifications are consistent.
- Tests can target policy findings, not only rendered strings.

Do not add custom policy DSLs, plugin systems, or organization policy management here.

## v0.5: Ecosystem Depth, Not Breadth

Purpose:

Improve precision in ecosystems already supported instead of adding broad new domains.

Priority areas:

- Node package manager conflicts
- Python uv/pip ambiguity
- SwiftPM and Xcode command selection
- Ruby Bundler dependency mutation
- Cargo and Go command guidance

Good Node conflict language:

```text
Prefer pnpm because pnpm-lock.yaml is present.
Ask before using npm because package-lock.json is also present.
```

Good Python fallback language:

```text
uv.lock is present, but uv is missing.
Ask before using pip as a fallback.
```

Package-manager version metadata may be added when it affects policy. Avoid adding version strings merely as environment inventory.

Completion criteria:

- Existing ecosystem ambiguity does not produce overconfident guidance.
- Lockfile conflict wording is stable.
- Missing preferred tool behavior is natural.
- Version metadata appears only when it changes command choice, approval requirements, or refusal decisions.

Do not add broad Docker, Terraform, Kubernetes, full Homebrew, or global package inventory scope.

## v0.6: Previous Scan Intelligence

Purpose:

Turn previous-scan comparison into a concise command-decision signal.

Focus:

- emphasize preferred-command changes
- show policy risk transitions briefly
- show secret-bearing file signal deltas without values
- show newly relevant missing tools
- keep detailed deltas in `environment_report.md`
- keep `agent_context.md` limited to command-changing drift

Good deltas:

```text
Previous scan preferred npm, but current scan prefers pnpm.
Ask before running npm install.
```

```text
A secret-bearing file signal appeared since the previous scan.
Do not read or print its contents.
```

Bad deltas:

```text
Detected file count changed from 184 to 187.
```

Completion criteria:

- Previous-scan notes do not make `agent_context.md` noisy.
- Only command-changing deltas appear in agent-facing output.
- Policy risk transitions are explainable.
- Secret-bearing file deltas never expose values.

Do not build a full diff viewer, Git history analyzer, project timeline, or changed-file dashboard.

## v0.7: Read-Only Agent Integrations

Purpose:

Make Habitat easier for agent workflows to consume while preserving the advisory, read-only boundary.

Candidate work:

- `--stdout agent-context`
- `--stdout command-policy`
- limited `--format` modes
- more stable machine-readable policy output
- setup guide for agent workflows
- minimal read-only MCP prototype, if the CLI contract is mature enough

Possible read-only MCP surface:

- `get_agent_context(project_path)`
- `get_command_policy(project_path)`
- `get_environment_report(project_path)`
- `explain_policy_decision(command)`

Explicitly out of scope:

- `approve_command`
- command blocking
- command execution
- missing-tool installation
- environment repair
- project mutation

Completion criteria:

- Agent workflows can read Habitat output without awkward file plumbing.
- Read-only boundaries are preserved.
- Integration docs repeat that policy is advisory, not enforcement.

## v0.8: Distribution and Trust

Purpose:

Make the tool easy to obtain without contradicting its own safety model.

Focus:

- GitHub Releases
- release notes
- checksums
- install and upgrade instructions
- changelog
- compatibility notes
- source archive clarity

Future macOS distribution candidates:

- Homebrew tap
- signed binary
- notarization

Avoid recommending `curl | sh` install flows. Habitat itself treats remote script piping as dangerous, so distribution should model the same caution.

Completion criteria:

- Users can obtain releases safely.
- Release-to-release changes are understandable.
- Version and schema compatibility are documented.
- Install instructions do not contradict the product's command policy philosophy.

## v0.9: Pre-1.0 Hardening

Purpose:

Separate stable commitments from still-experimental behavior.

Stabilize:

- basic CLI command shape
- output filenames
- `agent_context.md` structure
- `command_policy.md` classifications
- core `scan_result.json` schema
- major reason-code categories
- exit-code semantics
- read-only scan principle
- secret value non-emission principle

Keep experimental if needed:

- ecosystem-specific rule details
- previous-scan comparison details
- MCP integration
- package-manager version metadata
- optional output modes

Focus:

- breaking-change policy
- deprecation policy
- schema migration notes
- fixture coverage review
- flaky test review
- docs cleanup
- issue backlog pruning

Completion criteria:

- The v1.0 promise is clear.
- Experimental areas are named.
- Output breaking-change rules exist.
- Major known risks have documented policies.

## v1.0: Stable Advisory Context Generator

Purpose:

Declare a narrow, stable, documented version of the core product.

Scope:

- macOS-first SwiftPM CLI
- read-only project scan
- stable core outputs
- stable core JSON schema
- concise `agent_context.md`
- explainable `command_policy.md`
- no secret values read or emitted
- tested core ecosystems
- documented limitations

Not required for v1.0:

- GUI
- full MCP platform
- command enforcement
- automatic repair
- global environment inventory
- Linux or Windows support guarantee
- organization policy management
- plugin marketplace

Success criteria:

- New users understand how to run it and what it does.
- The AI-facing output is short.
- Policy reasons are explainable.
- Dangerous command guidance is consistent.
- Major fixtures do not regress.
- Stable and experimental schema areas are clear.

Suggested v1.0 positioning:

```text
Stable advisory context generation for AI coding agents.
```

## Backlog Classes

### P0: Public and Output Trust

- output length budget
- schema and generator version metadata
- reason codes
- prompt-injection policy tests
- issue templates
- examples
- CI hardening

### P1: Contract and Behavior

- fixed `agent_context.md` structure
- command-policy reason text
- behavior evaluation fixtures
- policy finding model
- renderer separation
- lockfile conflict tests
- missing preferred tool scenarios

### P2: Focused Depth and Read-Only Access

- pip/uv guidance refinement
- SwiftPM/Xcode guidance refinement
- policy-relevant package-manager version metadata
- previous-scan command-changing deltas
- stdout or format modes
- read-only MCP prototype

### Parking Lot

- GUI
- automatic repair
- command enforcement
- plugin system
- custom policy DSL
- organization or team policy management
- broad Docker/Kubernetes/Terraform support
- global package inventory
- full Homebrew scanner
- Linux or Windows support guarantee

Parking Lot does not mean never. It means not in the current roadmap.

## Issue Triage

Public issues should be evaluated with this checklist:

1. Is it a project-local signal?
2. Does it change command choice?
3. Does it affect secret, mutation, or global state risk?
4. Can `agent_context.md` stay short?
5. Does it fit the current policy model naturally?

If most answers are no, defer it even if the idea is useful.

## v0.x Pitfalls

Avoid becoming a convenient environment diagnostics CLI:

- installed tools list
- full Homebrew formula list
- global npm packages
- broad shell config analysis

Avoid behaving like an enforcement safety product:

- command approval
- command blocking
- OS-level enforcement claims
- agent execution control

Avoid becoming a broad agent platform too early:

- workflow manager
- task runner
- policy server
- large MCP surface
- editor plugin ecosystem

Read-only integration may be useful later. Execution, approval, and repair should wait until the advisory core is mature.
