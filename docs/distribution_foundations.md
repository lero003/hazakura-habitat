# Distribution Foundations

This guide is for agents, automations, and local scripts that need to obtain,
verify, and consume Habitat output without turning Habitat into an installer or
command runner.

Habitat remains advisory. These paths verify artifacts and print generated
context; they do not install Habitat globally, edit shell startup files, repair
projects, approve commands, or enforce policy.

## Choose A Consumption Path

Use the path that matches the job:

- Use `habitat-scan scan --project . --output ./habitat-report` when a durable
  report snapshot should remain on disk for review or comparison.
- Use `habitat-scan scan --project . --stdout agent-context` when an automation
  or local script only needs the short working context.
- Use `habitat-scan scan --project . --stdout command-policy` only before a
  risky, mutating, remote, secret-adjacent, archive/copy/sync, or
  environment-sensitive command needs full policy detail.
- Use `scripts/print_habitat_artifact.sh` when a script needs one stdout
  artifact after checking binary version, `generatorVersion`, preview
  `schemaVersion`, and generated artifact metadata.
- Use `scripts/verify_habitat_release.sh` or
  `scripts/print_habitat_release_artifact.sh` when consuming downloaded release
  assets. These helpers keep checksum verification first.

Do not combine `--stdout` and `--output`. A direct stdout artifact is for a
single pipeline step; durable report files are for saved context.

## Local Source Checkout

For development from this repository:

```bash
swift build
./.build/debug/habitat-scan scan --project . --stdout agent-context
```

When a durable report is needed:

```bash
./.build/debug/habitat-scan scan --project . --output ./habitat-report
```

For metadata-driven scripts, report filenames can be passed back directly:

```bash
./.build/debug/habitat-scan scan --project . --stdout agent_context.md
./.build/debug/habitat-scan scan --project . --stdout ./command_policy.md
./.build/debug/habitat-scan scan --project . --stdout habitat-report/agent_context.md
./.build/debug/habitat-scan scan --project . --stdout /path/to/project/habitat-report/agent_context.md
```

The `habitat-report/filename` form, including an absolute saved-report path, is
normalized to the generated artifact name only when `habitat-report` is a real
path component followed by the artifact filename. It is useful when an
automation already has a saved report path in hand but wants to switch to direct
stdout consumption.

## Verified Local Binary

When a script already has a chosen Habitat binary path, check the binary and
generated metadata before using saved or piped guidance:

```bash
scripts/check_habitat_metadata.sh /path/to/habitat-scan . 0.9.0
```

To print one verified artifact without creating `habitat-report/`:

```bash
scripts/print_habitat_artifact.sh /path/to/habitat-scan . agent_context.md 0.9.0
```

Successful metadata checks prove the binary version, generated
`generatorVersion`, expected preview `schemaVersion`, and core generated
Markdown artifact metadata agree, including entry sections and the
`agent_context.md` line budget. They do not prove that a saved old report is
fresh; regenerate when key project files changed after the report's
`Scanned at` timestamp.

## Downloaded Release Directory

Keep `SHA256SUMS`, `habitat-scan-macos.zip`, and the standalone `habitat-scan`
asset in the same downloaded release directory. Verify checksums before any
downloaded binary runs:

```bash
scripts/verify_habitat_release.sh /path/to/downloaded-release . 0.9.0
```

To pipe one verified release artifact to an agent or automation step:

```bash
scripts/print_habitat_release_artifact.sh /path/to/downloaded-release . agent_context.md 0.9.0
scripts/print_habitat_release_artifact.sh /path/to/downloaded-release . habitat-report/agent_context.md 0.9.0
```

The release helpers reject checksum paths that escape the release directory,
selected release assets that are missing from `SHA256SUMS`, zip entries that
escape the temporary extraction directory, symlinked verified binaries, and
non-regular binary paths before metadata or artifact checks run. The release
artifact print helper accepts the same report-filename and saved-report path
aliases as `scripts/print_habitat_artifact.sh`; it still regenerates and prints
the requested stdout artifact rather than reading an old report file.

## What Not To Do

- Do not use `curl | sh` or remote script piping to install or run Habitat.
- Do not skip `SHA256SUMS` verification for downloaded release assets.
- Do not treat `--version` as a substitute for checksum verification.
- Do not edit shell startup files or install globally unless a user explicitly
  asks for that environment mutation.
- Do not treat Habitat output as command approval or enforcement.
