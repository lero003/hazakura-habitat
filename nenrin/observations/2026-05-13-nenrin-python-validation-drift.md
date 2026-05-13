---
type: nenrin_observation
id: nenrin-python-validation-drift
date: 2026-05-13
related_changes:
  - python-unittest-validation-preference
  - post-v0-6-roadmap-automation-handoff
  - venv-python-symlink-guidance
impact_judgment: effective
success_tags:
  - watched_project_feedback_preserved
  - bounded_validation_followup_identified
  - pytest_overpromotion_removed
  - unittest_runner_fit_covered
failure_tags:
  - preferred_command_not_runnable
---

# Observation: nenrin-python-validation-drift

## Task

Nenrin-side review of Habitat guidance after `v0.6.0` and early `v0.7` roadmap handoff.

## Observed Behavior

- Habitat could prefer `.venv/bin/python -m pytest` when a project-local virtualenv interpreter existed.
- Nenrin's repository guidance and tests point to unittest, while pytest is not installed.
- The preferred command could therefore drift from the validation command that actually runs in the watched Python project.

## Success Signals Observed

- The watched-project feedback identified a concrete command-decision gap instead of a broad Python scanner request.
- The follow-up stayed bounded to validation-runner fit: verify pytest itself and inspect repo-backed unittest signals before rendering pytest as preferred.
- Focused Swift Testing coverage now pins both documented unittest guidance and inferred unittest test files.
- A sanitized behavior fixture records the command-decision boundary without copying watched-project report output.

## Failure Signals Observed

- Future Python runner kinds could still expose a similar fit issue if they repeatedly change first-command guidance.

## Impact Judgment

effective

## Next Action

- Do not expand Python validation taxonomy further unless repeated observations show another runner distinction changing first-command guidance.
