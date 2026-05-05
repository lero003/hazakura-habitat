---
type: nenrin_change
id: speculative-context-annotation-framing
date: 2026-05-06
status: observing
impact: unknown
related_files:
  - CHANGELOG.md
  - docs/current_status.md
  - docs/development_loop.md
  - docs/roadmap.md
review_after:
  tasks: 3
  days: 7
---

# Change: speculative-context-annotation-framing

## Changed

- Framed `v0.5` context work as `repo fact -> short annotation -> command decision`.
- Defined the initial annotation categories as `Facts`, `Hints`, `Warnings`, and `Open uncertainty`.
- Clarified that Habitat does not produce plans and that confidence should start as coarse `high` / `medium` / `low` labels.

## Reason

External planning discussion clarified that "speculative context" should not become automatic planning. Habitat should keep building a repository map, cut out short annotations for the next task, and let tests, review, human judgment, and Nenrin decide later whether those annotations helped.

## Expected Behavior

- Future `v0.5` slices stay small and command-changing.
- Agents treat `Hints` as hypotheses, `Warnings` as constraints, `Facts` as observations, and `Open uncertainty` as a refusal to guess.
- Nenrin observations can later mark an annotation as useful, misleading, too broad, or ready to prune.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- A future evidence or instruction-alignment slice changes an agent's verify/ask/stop decision without generating a full plan.
- The annotation category makes the generated context easier to trust or prune.
- No broad `NormalizedEvidence` model, prose linter, or planner layer appears before a measured command-decision need.

## Failure Signals

- Habitat starts recommending detailed implementation plans.
- Confidence labels are treated as precise scores.
- Generated context grows because annotations repeat `AGENTS.md` instead of surfacing repository facts.

## Result

Unjudged.
