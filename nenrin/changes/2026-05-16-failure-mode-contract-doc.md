---
type: nenrin_change
id: failure-mode-contract-doc
date: 2026-05-16
status: observing
impact: unknown
related_files:
  - docs/agent_contract.md
  - CHANGELOG.md
review_after:
  tasks: 3
  days: 7
---

# Change: failure-mode-contract-doc

## Changed

- Added a compact `v0.9` failure-mode classification table to
  `docs/agent_contract.md`.
- Mapped checksum, metadata, stdout/output, previous-scan, schema,
  generator-version, freshness, and diagnostic-report misuse cases to
  `Failure`, bounded uncertainty, or docs-only misuse.

## Reason

The implementation already has several narrow failure and uncertainty paths,
but the agent-facing contract did not keep those postures together. That makes
future hardening runs more likely to re-argue whether a mismatch should fail,
warn, or only change reading order. A single table keeps the next run on the
existing boundary instead of expanding Habitat into installation, repair, or
command enforcement.

## Expected Behavior

- Agents stop on checksum and helper metadata mismatches before trusting
  generated guidance.
- Agents treat unreadable previous scans, schema/generator differences, and
  observed-file drift as bounded uncertainty that prefers current generated
  Markdown.
- Agents keep `environment_report.md` diagnostic-only instead of using it as
  the first working context.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Future `v0.9` slices reuse the failure-mode table when deciding whether to
  add code, tests, helper checks, or no-op.
- No helper or docs change implies Habitat installs, repairs, approves,
  blocks, or enforces commands.

## Failure Signals

- Future runs still add new warning/failure language in scattered docs without
  updating the central table.
- Agents treat previous-scan metadata drift as a hard failure or release-helper
  metadata drift as a mere warning.

## Result

Unjudged.
