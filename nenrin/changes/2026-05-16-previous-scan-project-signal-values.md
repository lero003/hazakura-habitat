---
type: nenrin_change
id: previous-scan-project-signal-values
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

# Change: previous-scan-project-signal-values

## Changed

- Added structured `previousValues` and `currentValues` to previous-scan
  `package_manager` and `lockfiles` changes.
- Kept the human `agent_context.md` summary unchanged while making
  `scan_result.json` less dependent on prose parsing for core project-signal
  drift.
- Updated the agent contract and current status wording so the structured
  `changes` boundary includes package-manager and lockfile deltas.

## Reason

`v0.9` hardening should make saved-report comparison consumable without forcing
agents or scripts to scrape summary text for the most basic project signals.
Package-manager and lockfile changes are first-order command-decision evidence,
so they should carry the same lightweight value arrays as other hardened
previous-scan deltas.

## Expected Behavior

- Machine consumers can identify previous and current package-manager or
  lockfile values directly from `scan_result.json`.
- Agents still rely on the current generated Markdown and command policy before
  choosing build, test, or dependency commands.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Future stale-report consumers use structured values for package-manager and
  lockfile deltas instead of parsing summary prose.
- The short previous-scan note remains readable while JSON carries the exact
  changed values.

## Failure Signals

- Consumers treat previous lockfiles as current command permission.
- `changes` value arrays grow into a broad full-schema stability promise instead
  of staying scoped to actionable previous-scan deltas.

## Result

Unjudged.
