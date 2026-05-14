---
type: nenrin_change
id: checksum-first-release-consumption
date: 2026-05-13
status: observing
impact: unknown
related_files:
  - README.md
  - skills/hazakura-habitat/SKILL.md
  - docs/current_status.md
  - docs/roadmap.md
  - scripts/verify_habitat_release.sh
  - scripts/print_habitat_release_artifact.sh
  - Tests/HabitatCoreTests/ScanExecutionInfrastructureTests.swift
review_after:
  tasks: 3
  days: 7
---

# Change: checksum-first-release-consumption

## Changed

- Made release consumption guidance checksum-first in README.
- Clarified that agents should not run downloaded release binaries when `SHA256SUMS` verification fails or omits the asset.
- Added release-binary version and saved-report `generatorVersion` checks to the bundled Habitat skill.
- Moved checksum-first release consumption and binary/report metadata verification out of the `v0.7` roadmap candidate list and into shipped slice wording after the helper/docs work landed.
- Added `scripts/verify_habitat_release.sh` so local scripts can preserve the
  checksum-first order before delegating to metadata verification, without
  installing Habitat or creating `habitat-report/`.
- Tightened `scripts/verify_habitat_release.sh` so `SHA256SUMS` entries with
  absolute paths or parent-directory segments fail before `shasum` or the
  downloaded binary can run, keeping release verification scoped to the release
  directory.
- Tightened `scripts/verify_habitat_release.sh` so
  `habitat-scan-macos.zip` entries with absolute paths or parent-directory
  segments fail before extraction or binary execution, keeping release
  verification scoped to the temporary extraction directory.
- Tightened `scripts/verify_habitat_release.sh` so the verified release binary
  path must not be a symlink before metadata verification or execution, keeping
  zip-based consumption from following an extracted binary link outside the
  temporary verification directory.
- Added `scripts/print_habitat_release_artifact.sh` so checksum-first release
  verification can feed a single generated artifact to stdout without exposing
  the temporary extracted binary path or creating `habitat-report/`.
- Tightened the metadata and artifact helpers so local or verified release
  binary paths must be regular executable files before version or metadata
  checks run.

## Reason

`v0.7` Distribution Foundations should make Habitat easier to obtain and consume without becoming an installer or repair tool. The safest small step is to make verification order explicit for agents and automation before adding any new distribution surface.

## Expected Behavior

- Agents verify downloaded release artifacts before running them.
- Automation checks both the binary version and saved report generator metadata before trusting generated Markdown from a release binary.
- Local scripts can run one release-directory verification command that fails
  before executing the binary when checksums do not match.
- Local scripts reject checksum files that try to verify paths outside the
  downloaded release directory.
- Local scripts reject release zips that try to extract paths outside the
  temporary verification directory.
- Local scripts reject symlinked verified binaries before metadata checks run.
- Local scripts reject non-regular binary paths before version or metadata
  checks run.
- Local scripts can consume `agent_context.md` or another generated artifact
  from a downloaded release directory while preserving checksum-first order and
  keeping verification output off stdout.
- Missing or failed checksum verification stops release-binary use instead of falling through to remote script piping, global installs, or package-manager mutation.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Future setup or automation work follows checksum-first consumption without needing extra user correction.
- Agents distinguish a stale saved report from a verified current binary.
- Release-helper tests prove checksum mismatch stops before binary execution.
- Release-helper tests prove path-escaping checksum entries stop before
  checksum verification and binary execution.
- Release-helper tests prove path-escaping zip entries stop before extraction
  and binary execution.
- Release-helper tests prove symlinked zip binaries stop before binary
  execution.
- Release-helper tests prove non-regular binary paths stop before metadata
  checks.
- Release artifact-print tests prove stdout stays artifact-only after checksum
  verification and that checksum failure stops before binary execution.

## Failure Signals

- Agents still run release binaries before checksum verification.
- Version checks are treated as a substitute for checksum verification.
- The guidance expands into automatic installation or repair behavior.
- The helper accepts checksum entries that escape the release directory.
- The helper accepts zip entries that escape the temporary extraction directory.
- The helper follows a symlinked release binary during metadata verification.
- The helper attempts version or metadata checks against a non-regular binary
  path.
- The release artifact print helper writes checksum status to stdout or runs the
  downloaded binary after a checksum failure.

## Result

Unjudged.
