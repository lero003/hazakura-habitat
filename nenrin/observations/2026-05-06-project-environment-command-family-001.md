---
type: nenrin_observation
id: project-environment-command-family-001
date: 2026-05-06
related_changes:
  - project-environment-command-family
impact_judgment: effective
success_tags:
  - drift_reduced
  - generated_output_stable
failure_tags: []
---

# Observation: project-environment-command-family-001

## Task

Run the post-`v0.4.0` self-use maintainability loop after SSH private-key extraction.

## Observed Behavior

- Self-scan still preferred `swift test` and `swift build` with no warnings.
- Virtual-environment and version-manager Ask First strings were still duplicated across policy generation, report prioritization, and reason classification.
- Extracting them reduced string drift while keeping the command decision unchanged.

## Success Signals Observed

- `swift test` passed with 207 tests.
- Catalog classification coverage confirms virtual-environment commands keep `user_approval_required` and version-manager commands keep `version_manager_mutation`.
- Self-scan command counts remained stable after the no-output-change extraction.

## Failure Signals Observed

- None observed in this slice.

## Impact Judgment

effective

## Next Action

- Keep the next catalog slice limited to one remaining command-decision family; do not widen into fallback reason restructuring.
