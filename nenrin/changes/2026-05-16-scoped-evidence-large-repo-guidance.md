---
type: nenrin_change
id: scoped-evidence-large-repo-guidance
date: 2026-05-16
status: observing
impact: unknown
related_files:
  - README.md
  - docs/product_direction.md
  - docs/roadmap.md
  - docs/development_loop.md
  - docs/current_status.md
  - CHANGELOG.md
review_after:
  tasks: 3
  days: 7
---

# Change: scoped-evidence-large-repo-guidance

## Changed

- Added development guidance that frames large-repository support as scoped
  evidence rather than whole-project understanding.
- Clarified that Habitat should prefer repository entrypoints, nearby files,
  command-relevant evidence, and explicit uncertainty before increasing scan
  breadth.
- Added `Scoped evidence over broad project interpretation` to the product
  principles.

## Reason

The user identified a strong product framing: experienced maintainers do not
understand a huge repository by reading everything; they make a bounded first
move by reading the likely entrypoints, nearby files, and command-relevant
configuration while leaving unknowns explicit. Habitat should teach AI agents
that disciplined restraint instead of encouraging false confidence.

## Expected Behavior

- Future large-repository proposals start with scope selection and explicit
  uncertainty, not broad scanner coverage.
- Automation treats monorepo or large-repo work as a command-decision boundary
  question rather than permission to build whole-project intelligence.
- README/product discussions describe Habitat as a bounded first-move map, not
  a claim of total project understanding.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Future agents ask which entrypoint, nearby path, or command-relevant file
  supports a claim before expanding scan breadth.
- Large-repository guidance produces useful `Open uncertainty` instead of
  confident but under-supported project interpretation.

## Failure Signals

- Habitat work starts adding broad project summaries, changed-file dashboards,
  or monorepo intelligence without a command-decision effect.
- Docs imply that reading more files is the default fix for unfamiliar or large
  repositories.

## Result

Unjudged.
