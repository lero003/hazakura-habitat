---
type: nenrin_change
id: v0-9-release-prep
date: 2026-05-17
status: observing
impact: unknown
related_files:
  - README.md
  - CHANGELOG.md
  - docs/current_status.md
  - docs/roadmap.md
  - docs/development_loop.md
  - docs/distribution_foundations.md
  - docs/known_limitations.md
  - Sources/HabitatCore/HabitatMetadata.swift
  - Sources/HabitatCore/ScanComparator.swift
review_after:
  tasks: 3
  days: 7
---

# Change: v0-9-release-prep

## Changed

- Cut the release-prep docs and version surfaces for v0.9.0 Developer Preview:
  generatorVersion, README/current status, roadmap first shipped slice,
  CHANGELOG, helper examples, representative generator-version examples, and
  post-v0.9 automation handoff.
- Added a small previous-scan compatibility-label guard so malformed external
  schema/generator labels are normalized before they appear in generated
  Markdown.

## Reason

External review agreed that current main should move into v0.9.0 release prep,
but not tag immediately. The required work is release-surface alignment plus a
small trust-boundary hardening item, not new scanner coverage.

## Expected Behavior

- Future agents describe v0.9.0 as the first Pre-1.0 hardening slice, centered
  on version-gated comparison, failure-mode boundaries, core Markdown artifact
  metadata, helper verification, and scoped evidence.
- Future release-prep runs check version strings, representative examples,
  self-scan generator visibility, release artifacts, and checksum verification
  before tagging.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Agents no longer treat `v0.9` as a generic feature lane or broad ecosystem
  expansion.
- Release notes stay focused on boundary sorting instead of replaying the full
  internal docs/Nenrin history.
- Previous-scan compatibility summaries do not echo malformed schema or
  generator labels into Markdown.

## Failure Signals

- Future work treats the whole `scan_result.json` schema as stable because
  core Markdown artifact metadata was promoted as a stable candidate.
- Tags or GitHub Release assets are moved after publication instead of using a
  transparent patch release for material corrections.

## Result

Unjudged.
