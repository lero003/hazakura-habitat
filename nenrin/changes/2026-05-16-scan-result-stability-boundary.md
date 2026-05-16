---
type: nenrin_change
id: scan-result-stability-boundary
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

# Change: scan-result-stability-boundary

## Changed

- Clarified the `scan_result.json` machine-artifact contract for `v0.9`.
- Marked the core Markdown artifact metadata as a narrow v1-stable candidate
  while keeping detailed navigation, sizing, and full JSON shape
  preview-scoped.
- Updated previous-scan compatibility wording so observed-file freshness and
  command-policy changes are included with structured `previousValues` /
  `currentValues` metadata.

## Reason

The top-level `v0.9` boundary already treated the core Markdown artifact
contract as a stable candidate, but the detailed machine-artifact section could
still be read as making all artifact metadata equally preview-scoped. That
ambiguity weakens release and helper trust decisions because scripts already
verify the core Markdown artifact contract while the rest of `scan_result.json`
should remain flexible before `v1.0`.

## Expected Behavior

- Future agents separate the stable-candidate Markdown artifact identity and
  read-order contract from preview-only line/count/detail metadata.
- Machine consumers use structured previous/current values for stale-report
  and command-policy deltas without treating the full `changes` shape as a
  frozen schema.
- Future `v0.9` slices classify only one narrow metadata boundary at a time.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Release/helper hardening continues to verify the core artifact contract
  without expanding to full JSON-schema stability.
- Previous-scan docs and implementation stay aligned on which deltas carry
  structured values.

## Failure Signals

- Future docs imply all `scan_result.json` fields are stable for `v1.0`.
- Agents ignore structured previous/current values and parse summary prose for
  stale-report or command-policy decisions.

## Result

Unjudged.
