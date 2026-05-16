---
type: nenrin_change
id: v0-9-phase-boundary
date: 2026-05-16
status: observing
impact: unknown
related_files:
  - README.md
  - docs/current_status.md
  - docs/development_loop.md
  - docs/roadmap.md
  - docs/self_use.md
review_after:
  tasks: 3
  days: 7
---

# Change: v0-9-phase-boundary

## Changed

- Reframed current main-branch work as `v0.9` Pre-1.0 hardening while keeping `v0.8.0` as the immutable published Developer Preview.
- Named the narrow stability-sorting lane: v1-stable candidates, preview metadata, docs-only guidance, and post-v1 deferrals.
- Moved the same boundary into recurring automation guidance and roadmap
  wording so future runs do not have to infer `v0.9` from the saved automation
  prompt alone.
- Marked the older self-use snapshot as historical evidence instead of the
  current work selector, and pointed active runs back to `current_status` plus
  `development_loop`.

## Reason

The project had shipped the v0.8 Observation -> Action slice, but the status docs still made future work read like more v0.8 observation. That stale phase wording could make recurring agents choose broad observation or distribution carry-over instead of a bounded Pre-1.0 hardening slice.

## Expected Behavior

- Future runs start by looking for a small v0.9 hardening boundary before considering new surface area.
- Agents keep released v0.8 tags and assets immutable unless a material patch-release issue appears.
- Stability work stays focused on existing contracts such as Markdown read order, previous-scan comparison, generator/version metadata, release consumption, helper behavior, examples, and adoption guidance.
- Docs-only runs remain valid only when stale phase or automation guidance would
  make the next run choose the wrong work; otherwise the loop prefers a
  product, test, fixture, helper, example, or output-contract slice.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Future v0.9 slices classify one stable/preview/docs-only/post-v1 boundary instead of expanding Habitat into planner, installer, enforcement, MCP, or Linux support work.
- No-op remains acceptable when no concrete hardening slice is justified.
- Recurring runs can read `docs/development_loop.md` and `docs/roadmap.md` for
  the same v0.9 contract-sorting guidance that exists in the saved automation
  prompt.
- Agents do not treat the 2026-05-09 v0.5 self-scan snapshot as current phase
  guidance when choosing the next v0.9 hardening slice.

## Failure Signals

- Recurring runs still describe the current lane as generic v0.8 observation.
- Agents treat v0.9 as permission to broaden scanner domains or declare the whole JSON schema stable.
- Agents use the old self-use snapshot as the main selector and re-open v0.5
  maintainability work without fresh evidence.

## Result

Unjudged.
