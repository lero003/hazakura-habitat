---
type: nenrin_change
id: development-forward-automation
date: 2026-05-15
status: observing
owner: Codex
impact: unknown
related_files:
  - docs/development_loop.md
  - docs/current_status.md
  - /Users/keisetsu/.codex/automations/hazakura-habitat-1/automation.toml
review_after:
  tasks: 3
  days: 7
---

# Change: development-forward-automation

## Summary

- Reframed post-`v0.7` automation so observation selects a concrete development
  slice instead of becoming the main deliverable.
- Clarified that handoff, automation prompt, and Nenrin-only work are valid only
  when stale guidance would make future runs choose the wrong work.

## Rationale

The first post-release automation update correctly moved Habitat from the
`v0.7` release-prep lane into `v0.8` Observation -> Action. But if recurring
runs keep producing only handoff or memory hygiene, the loop stops advancing
the product. `v0.8` should turn observed consumption, freshness, release-trust,
or command-decision friction into one small repo-local improvement.

## Expected effect

- Future automation treats cross-project and release consumption observation as
  input to work selection, not as the work itself.
- A normal run prefers a focused code, test, docs, fixture, helper, or
  output-contract slice.
- No-op remains acceptable when no safe repo-local slice is justified.

## Review

Look for the next few automation runs ending in committed product/docs/test
improvements or clearly justified no-ops, rather than repeated handoff-only
changes.
