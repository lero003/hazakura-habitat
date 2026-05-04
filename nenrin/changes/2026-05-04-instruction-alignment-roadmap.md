---
type: nenrin_change
id: instruction-alignment-roadmap
date: 2026-05-04
status: observing
impact: unknown
related_files:
  - README.md
  - docs/roadmap.md
  - docs/product_direction.md
  - docs/current_status.md
  - docs/development_loop.md
  - docs/self_use.md
review_after:
  tasks: 3
  days: 7
---

# Change: instruction-alignment-roadmap

## Changed

- Renamed the provisional `v0.5` direction from Evidence Normalization to Evidence and Instruction Alignment.
- Clarified that Habitat should complement `AGENTS.md` and project docs rather than duplicate them.
- Added instruction-drift and repository-reality checks as future Habitat success criteria.
- Clarified that self-scans should be used before high-impact work, not as a ritual for every tiny edit.
- Clarified that skipping Habitat is acceptable when current project docs already answer a low-risk command question.

## Reason

Real cross-project use showed that Habitat is weak when its output mostly repeats written instructions. Its stronger value is as an initial audit tool: package-manager signals, missing or unverifiable tools, secret-bearing paths, generated-output state, and release or CI risk that written guidance alone does not prove.

## Expected Behavior

- Future Habitat work prioritizes command-changing repository facts over broad instruction restatement.
- `v0.5` slices start from one measured instruction-alignment or normalized-evidence case instead of a generic architecture layer.
- Agents use Habitat before high-impact or unfamiliar work, while letting `AGENTS.md` remain the immediate rule source.
- Evaluation distinguishes successful no-scan sessions from missed preflight cases.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- A future self-use case shows Habitat surfacing a mismatch or fact that changed the next command.
- `agent_context.md` stays concise and avoids repeating long project guidance.
- Habitat evaluation can compare first-agent behavior with `AGENTS.md` alone versus `AGENTS.md` plus Habitat context.
- A no-scan session is accepted as healthy when `AGENTS.md` was sufficient and no later command mistake appears.

## Failure Signals

- The next roadmap slice becomes a generic prose linter or broad scanner expansion.
- Generated context duplicates project instructions without adding current repository facts.
- Self-scan cost increases without catching a command-changing fact.
- Teams run Habitat as ritual even when `AGENTS.md` already answers the low-risk task.

## Result

Unjudged.
