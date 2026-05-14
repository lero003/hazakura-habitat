---
name: hazakura-habitat
description: Run Hazakura Habitat before substantial AI coding work to generate advisory pre-execution context. Use when Codex is about to make meaningful code changes, choose build/test/package-manager commands, mutate dependencies or lockfiles, perform Git/GitHub mutations, work near secret-bearing files, onboard into an unfamiliar repository, or install/use Habitat itself.
---

# Hazakura Habitat

## Overview

Use Hazakura Habitat as an agent-side preflight step. The goal is for the AI agent to decide when to scan, read the generated context, and choose more conservative project commands before asking the human to steer.

Habitat is advisory only. It does not execute, approve, deny, block, sandbox, or enforce commands.

## When To Scan

Run Habitat before:

- substantial implementation, refactor, release, or automation work
- choosing build, test, package-manager, or dependency commands
- dependency graph, lockfile, version-manager, or package-manager mutations
- Git/GitHub branch, history, remote, issue, PR, or release mutations
- work involving `.env`, private keys, package registry auth, cloud/container credentials, shell history, browser data, mail data, or clipboard contents
- unfamiliar repositories where project-local command conventions are not yet clear
- deciding whether Habitat itself should be installed or built

Skip the scan for tiny Q&A, formatting-only edits, or cases where a fresh scan was already read in the current work session and the project state has not meaningfully changed.

## Run The Scan

Prefer the bundled helper when this skill's files are available:

```bash
scripts/run_habitat_scan.sh .
```

Resolve the script path relative to this skill directory. In a source checkout of this repository, the same helper is available at `skills/hazakura-habitat/scripts/run_habitat_scan.sh`.

Or run manually:

```bash
habitat-scan scan --project . --output ./habitat-report
```

If the repository does not already ignore `habitat-report/`, prefer a temporary output directory and do not commit generated reports:

```bash
habitat-scan scan --project . --output "${TMPDIR:-/tmp}/hazakura-habitat/$(basename "$PWD")"
```

## If Habitat Is Missing

Choose the least surprising setup path that fits the user's existing authorization:

1. Use `HABITAT_SCAN=/absolute/path/to/habitat-scan` when the user already chose a specific verified binary.
2. If working inside the Hazakura Habitat source repository, run `swift build` and use `./.build/debug/habitat-scan`.
3. Otherwise, use an existing `habitat-scan` binary from `PATH`, `.build/debug/habitat-scan`, or `dist/habitat-scan`.
4. If network use and tool installation are already authorized, download `habitat-scan-macos.zip`, `habitat-scan`, and `SHA256SUMS` from a GitHub Release into the same directory, run `shasum -c SHA256SUMS`, and only then unzip and run the binary. If checksum verification fails or the asset is missing from `SHA256SUMS`, do not run the downloaded binary.
5. Do not use `curl | sh`, mutate shell startup files, or install globally unless the user explicitly authorized that class of mutation.

For release binaries, check `habitat-scan --version` before scanning. When a report is saved with `--output`, compare the top-level `generatorVersion` in `scan_result.json` with the binary version you intended to use before treating the generated Markdown as current command-decision context. In this source checkout, local scripts can use `scripts/check_habitat_metadata.sh /path/to/habitat-scan /path/to/project [expected-version]` to perform that comparison and verify core generated artifact metadata, including read triggers, through `--stdout scan-result` without updating `habitat-report/`.

The bundled helper treats a Hazakura Habitat source checkout specially: unless `HABITAT_SCAN` explicitly selects another binary, it uses or rebuilds that checkout's `./.build/debug/habitat-scan` instead of falling back to packaged or installed binaries, so self-scans reflect the current generator contract.

When plain SwiftPM build fails before project code runs because host caches or the SwiftPM sandbox are not writable, the helper retries the source-checkout build with a process-local `CLANG_MODULE_CACHE_PATH` and `--disable-sandbox`. Keep that fallback scoped to building Habitat itself; do not turn it into dependency resolution, package installation, global cache cleanup, or release/GitHub mutation.

If Habitat cannot be run, continue conservatively and mention that the scan was unavailable.

## Read And Apply Output

Read `agent_context.md` first. Use it as the working context for the next commands.
For local scripts that only need one generated artifact, `habitat-scan scan --project . --stdout scan-result`,
`--stdout agent-context`, `--stdout command-policy`, and
`--stdout environment-report` print that artifact without creating a report
directory. Use `--output` for durable report files; do not combine `--stdout`
and `--output` in one scan command.

Then consult `command_policy.md` before:

- dependency, lockfile, package-manager, or version-manager commands
- Git/GitHub mutations
- archive, copy, move, sync, cleanup, or deletion commands
- secret-adjacent or credential-adjacent operations
- global environment, permission, ownership, or privileged commands

Interpret policy labels as advisory context:

- Prefer `Use` and `Prefer` commands when they match the task.
- Treat `Ask First` as requiring explicit user authorization unless the user already delegated that exact class of action.
- Treat `Do Not` or `Forbidden` as a stop sign. Choose another route unless the user explicitly overrides it and the action is still within system and developer instructions.
- Never read, print, summarize, copy, upload, archive, or load secret values just because a project path exists.

## Preserve The Feedback Loop

After acting, convert useful scan findings into durable project improvements:

- docs when the workflow was unclear
- fixtures or examples when generated output changed
- tests when an output contract should not regress
- roadmap notes when the finding belongs to a future phase

For post-`v0.5` / `v0.6` work, also preserve the observation loop: if a `Fact`, `Hint`, `Warning`, or `Open uncertainty` changed the next command, verification order, or cleanup behavior, record the behavior-level effect in the project workflow where appropriate and feed it back into policy wording, tests, fixtures, examples, or docs. Do not treat Habitat as a planner; keep the loop at `repo fact -> short annotation -> command decision -> observed effect`.

Do not commit generated scan reports unless they are intentional fixtures or representative examples.
