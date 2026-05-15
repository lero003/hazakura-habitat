---
id: narrow-depth-platform-boundary
status: observing
owner: Codex
created: 2026-05-15
review_after: 2026-05-22
tracked_files:
  - docs/product_direction.md
  - docs/current_status.md
  - docs/development_loop.md
  - docs/roadmap.md
  - CHANGELOG.md
  - /Users/keisetsu/.codex/automations/hazakura-habitat-1/automation.toml
---

# Change: narrow-depth-platform-boundary

## Summary

- Recorded the product judgment that Habitat should prefer narrow depth over
  platform breadth.
- Reframed Linux from a default carry-over candidate into optional portability
  notes only when they protect the macOS-first advisory CLI contract.

## Rationale

`v0.8` Observation -> Action already defers broad expansion, but roadmap wording
still placed Linux feasibility near `--format` and thin read-only MCP. That can
make future runs treat Linux as the next natural growth lane. The user clarified
that MCP may become useful later, but broad Linux/platform expansion is not
strategic for Habitat right now.

## Expected effect

- Future automation keeps the macOS / SwiftPM proving ground deep instead of
  starting platform reach work.
- Portability notes are allowed only to prevent concrete release-trust or
  command-decision mistakes.
- Linux or Windows support guarantees remain out of scope.

## Review

Check whether future `v0.8` slices continue to deepen command-decision quality,
freshness, validation-purpose fit, and agent adoption instead of opening a
platform support track.
