---
type: nenrin_change
id: agent-context-warning-label
date: 2026-05-12
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/ReportWriter.swift
  - Tests/HabitatCoreTests/PythonPackagePolicyTests.swift
  - Tests/HabitatCoreTests/CoreInfrastructureTests.swift
  - examples/
  - docs/current_status.md
review_after:
  tasks: 3
  days: 7
---

# Change: agent-context-warning-label

## Changed

- Changed `agent_context.md` Notes output from `Mismatch:` / `Mismatches: none detected` to `Warning:` / `Warnings: none detected`.
- Updated representative examples and output-contract tests to preserve the new label.
- Added a Python `.venv` contract so healthy project-local interpreter guidance is not rendered as a mismatch.

## Reason

Cross-project observation of Nenrin produced healthy `.venv/bin/python` guidance, but the short context rendered it as `Mismatch:`. That wording can make a normal command preference look like contradictory repository evidence.

## Expected Behavior

- Agents read cautionary command guidance as warnings, not proof that project facts disagree.
- Real instruction-alignment contradictions remain in their explicit Fact / Warning / Hint / Open uncertainty annotations.
- Future warning examples keep the label concise and do not reintroduce a separate mismatches section.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later self-use or sibling-project intake does not over-treat healthy `.venv`, missing-tool, or version-check guidance as stale or contradictory state.
- Generated examples and snapshot tests catch accidental return to the old label.

## Failure Signals

- Agents ignore warnings because the wording is too soft for actual command-risk cases.
- A future instruction-drift case needs a distinct contradiction label that this change made harder to express.

## Result

Unjudged.
