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

## Reason

`v0.7` Distribution Foundations should make Habitat easier to obtain and consume without becoming an installer or repair tool. The safest small step is to make verification order explicit for agents and automation before adding any new distribution surface.

## Expected Behavior

- Agents verify downloaded release artifacts before running them.
- Automation checks both the binary version and saved report generator metadata before trusting generated Markdown from a release binary.
- Missing or failed checksum verification stops release-binary use instead of falling through to remote script piping, global installs, or package-manager mutation.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Future setup or automation work follows checksum-first consumption without needing extra user correction.
- Agents distinguish a stale saved report from a verified current binary.

## Failure Signals

- Agents still run release binaries before checksum verification.
- Version checks are treated as a substitute for checksum verification.
- The guidance expands into automatic installation or repair behavior.

## Result

Unjudged.
