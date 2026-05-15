---
type: nenrin_change
id: previous-scan-schema-version-delta
date: 2026-05-16
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/ScanComparator.swift
  - Tests/HabitatCoreTests/ScanComparisonTests.swift
  - docs/current_status.md
review_after:
  tasks: 3
  days: 7
---

# Change: previous-scan-schema-version-delta

## Changed

- Added an explicit `schema` change category when `--previous-scan` compares two reports with different `schemaVersion` values.
- Pinned the ordering before generator-version deltas so agents see preview-format drift before interpreting policy-generator drift.

## Reason

`schemaVersion` is one of the few metadata fields that can become part of the v1-stable boundary. During v0.9 hardening, old reports with a different schema should be treated as preview-format context, not just ordinary environment drift or a silent successful comparison.

## Expected Behavior

- Agents reading `agent_context.md` see schema-version drift as bounded uncertainty and rely on the current generated Markdown before choosing commands.
- Machine consumers can inspect `scan_result.json` `changes[].category == "schema"` instead of inferring schema drift from generator changes.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Future previous-scan comparisons distinguish schema drift from package-manager, freshness, and generator-only changes.
- No broad schema-stability promise is added before v1.

## Failure Signals

- Agents still treat mismatched-schema reports as fully comparable current facts.
- The schema delta becomes a substitute for validating current `agent_context.md` and `command_policy.md`.

## Result

Unjudged.
