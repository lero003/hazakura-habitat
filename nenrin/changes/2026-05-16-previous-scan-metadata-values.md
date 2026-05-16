---
type: nenrin_change
id: previous-scan-metadata-values
date: 2026-05-16
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/ScanComparator.swift
  - Tests/HabitatCoreTests/ScanComparisonTests.swift
  - docs/agent_contract.md
  - docs/current_status.md
review_after:
  tasks: 3
  days: 7
---

# Change: previous-scan-metadata-values

## Changed

- Added structured `previousValues` and `currentValues` to previous-scan
  `schema` and `generator` deltas.
- Documented that schema-version and generator-version changes are machine
  readable compatibility-boundary signals, not only Markdown summary text.

## Reason

`v0.9` hardening should make the stable/preview boundary easier for scripts and
agents to consume. Schema and generator changes are compatibility facts; they
should not require parsing human summary prose before deciding whether an old
report is bounded stale context.

## Expected Behavior

- Agents still rely on current generated Markdown when schema or generator
  versions differ.
- Machine consumers can inspect structured values for metadata drift before
  interpreting environment, preferred-command, or policy deltas.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Future previous-scan consumers treat schema/generator mismatch as bounded
  compatibility context without scraping summaries.
- The change does not expand the v1 stable promise beyond this narrow metadata
  comparison boundary.

## Failure Signals

- Consumers treat matching schema/generator values as proof that an old report
  is fresh.
- The metadata value arrays are mistaken for a stable full-schema declaration.

## Result

Unjudged.
