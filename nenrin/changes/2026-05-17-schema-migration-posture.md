---
type: nenrin_change
id: schema-migration-posture
date: 2026-05-17
status: observing
impact: unknown
related_files:
  - docs/agent_contract.md
  - docs/current_status.md
  - docs/roadmap.md
  - CHANGELOG.md
review_after:
  tasks: 3
  days: 7
---

# Change: schema-migration-posture

## Changed

- Added a pre-`v1.0` compatibility and deprecation posture to
  `docs/agent_contract.md`.
- Clarified that `schemaVersion` gates unsafe preview-format changes while
  `generatorVersion` records release provenance.
- Narrowed roadmap/status wording so future work applies the posture to one
  stable-candidate boundary at a time.

## Reason

Post-`v0.9.0` work should not keep re-arguing whether preview metadata changes
are additive, breaking, or release-provenance-only. A small central posture lets
future slices classify one boundary without promoting the full JSON schema or
inventing a migration framework.

## Expected Behavior

- Additive preview metadata can continue without a schema bump when current
  Markdown remains the command-decision authority.
- Renames, removals, or semantic changes to machine-consumed fields require a
  documented schema change.
- Field promotion waits for named contract wording plus tests, examples, or
  helper checks.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Future `v1.0` readiness slices cite the central posture before promoting or
  changing a stable-candidate field.
- Automation chooses one contract boundary instead of broad schema-stability
  work.

## Failure Signals

- Future docs imply the whole `scan_result.json` schema is stable.
- A machine-consumed field is removed or redefined without a schema-change note.

## Follow-up Observation

- A later contract pass found the `scan_result.json` shape example still used an
  old generator version. The example now says it is representative and uses the
  current `v0.9.0` generator baseline so future compatibility work does not
  confuse release provenance with schema stability.

## Result

Unjudged.
