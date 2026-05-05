---
type: nenrin_change
id: policy-catalog-git-boundary-guidance
date: 2026-05-05
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

# Change: policy-catalog-git-boundary-guidance

## Changed

- Added post-`v0.4` guidance that the next safe maintainability slice is a no-behavior-change Git/GitHub command-family extraction from `PolicyReasonCatalog`.
- Named the intended boundary as a Swift extension such as `PolicyReasonCatalog+Git.swift`.
- Explicitly excluded reason-rule ordering, dependency-mutation fallback, credential/auth families, DSLs, plugins, and external rule formats from that slice.

## Reason

External review agreed that `v0.5` behavior work should not begin by creating a broad `NormalizedEvidence` layer or generic instruction-prose checker. `PolicyReasonCatalog.swift` is the current maintainability warning light, and Git/GitHub command families are a cohesive first extraction that can prove the split pattern while preserving generated output behavior.

## Expected Behavior

- Future automation chooses a narrow Git/GitHub command-family boundary slice before broad v0.5 behavior work.
- The slice preserves command order, reason-code mapping, `commandReasons`, `reviewFirstCommandReasons`, `command_policy.md`, and `scan_result.json`.
- Agents do not mix dependency fallback changes, credential/auth extraction, DSLs, plugins, or external rule formats into the same slice.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- A future catalog split keeps generated output stable and passes focused Git/GitHub reason-code tests plus full `swift test`.
- The extraction creates a reusable file-boundary pattern without changing policy semantics.
- v0.5 evidence or instruction-alignment work starts after the catalog boundary is clearer.

## Failure Signals

- The slice changes generated policy output or reason codes unexpectedly.
- Broad dependency fallback behavior is modified in the same change.
- The change grows into a DSL, plugin system, external rule format, or generic instruction linter.

## Result

Unjudged.
