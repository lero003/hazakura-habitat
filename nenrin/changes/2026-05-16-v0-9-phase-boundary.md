---
type: nenrin_change
id: v0-9-phase-boundary
date: 2026-05-16
status: observing
impact: unknown
related_files:
  - README.md
  - docs/current_status.md
review_after:
  tasks: 3
  days: 7
---

# Change: v0-9-phase-boundary

## Changed

- Reframed current main-branch work as `v0.9` Pre-1.0 hardening while keeping `v0.8.0` as the immutable published Developer Preview.
- Named the narrow stability-sorting lane: v1-stable candidates, preview metadata, docs-only guidance, and post-v1 deferrals.

## Reason

The project had shipped the v0.8 Observation -> Action slice, but the status docs still made future work read like more v0.8 observation. That stale phase wording could make recurring agents choose broad observation or distribution carry-over instead of a bounded Pre-1.0 hardening slice.

## Expected Behavior

- Future runs start by looking for a small v0.9 hardening boundary before considering new surface area.
- Agents keep released v0.8 tags and assets immutable unless a material patch-release issue appears.
- Stability work stays focused on existing contracts such as Markdown read order, previous-scan comparison, generator/version metadata, release consumption, helper behavior, examples, and adoption guidance.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Future v0.9 slices classify one stable/preview/docs-only/post-v1 boundary instead of expanding Habitat into planner, installer, enforcement, MCP, or Linux support work.
- No-op remains acceptable when no concrete hardening slice is justified.

## Failure Signals

- Recurring runs still describe the current lane as generic v0.8 observation.
- Agents treat v0.9 as permission to broaden scanner domains or declare the whole JSON schema stable.

## Result

Unjudged.
