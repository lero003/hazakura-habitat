---
type: nenrin_change
id: python-unittest-validation-preference
date: 2026-05-13
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/ProjectDetector.swift
  - Sources/HabitatCore/Scanner.swift
  - Tests/HabitatCoreTests/PythonPackagePolicyTests.swift
  - examples/behavior-evaluation/python-unittest-validation-001.json
  - docs/development_loop.md
review_after:
  tasks: 3
  days: 7
---

# Change: python-unittest-validation-preference

## Changed

- Added a project-pytest availability check before promoting project-virtualenv pytest as a preferred Python command.
- Added bounded unittest signals from repo docs, release checklists, and top-level Python test files.
- Preferred project-virtualenv unittest validation when repo-backed unittest signals exist.
- Added focused Swift Testing coverage and a sanitized behavior fixture for the Nenrin-derived drift case.
- Adjusted automation-facing wording so Habitat self-scans do not misread the Python follow-up as this repo's own validation command.

## Reason

Nenrin feedback showed a concrete first-command drift: a Python repo could expose a runnable project virtualenv while its docs and tests use unittest and pytest is not installed. Promoting pytest from interpreter existence alone made Habitat guidance look more confident than the repository facts supported.

## Expected Behavior

- Python projects with repo-backed unittest signals prefer unittest through the project virtualenv.
- Project-virtualenv pytest is preferred only after the project interpreter confirms pytest is runnable.
- uv projects without a concrete runnable project pytest target do not fall back to system pytest.
- Future automation treats this as a narrow runner-fit correction, not a broad Python taxonomy opening.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Nenrin-style Python projects no longer receive pytest as the first preferred command when unittest is the repo-backed runner.
- Habitat self-scans keep SwiftPM as the only ordinary local validation preference.
- No new broad setup, lint, smoke, package, or CI runner taxonomy appears without repeated command-decision evidence.

## Failure Signals

- Agents still choose pytest for unittest projects because generated output is ambiguous.
- Python runner-fit logic starts treating unrelated test frameworks as broad scanner scope without evidence.
- Self-scans emit multi-workflow uncertainty from roadmap or automation meta-discussion.

## Result

Unjudged.
