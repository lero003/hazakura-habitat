---
type: nenrin_change
id: javascript-package-manager-mutation-command-families
date: 2026-05-04
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/PolicyReasonCatalog.swift
  - Sources/HabitatCore/Scanner.swift
  - Tests/HabitatCoreTests/HabitatCoreTests.swift
  - docs/current_status.md
review_after:
  tasks: 3
  days: 7
---

# Change: javascript-package-manager-mutation-command-families

## Changed

- Centralized npm, pnpm, yarn, and bun dependency-mutation command arrays in `PolicyReasonCatalog`.
- Made scanner Ask First command generation and selected package-manager review ordering consume those catalog-owned arrays.
- Added focused coverage that the selected JavaScript review commands classify as `dependency_mutation`, including `yarn up`.

## Reason

The v0.3 self-use report kept the next implementation path on policy review before Git mutation and showed that `command_policy.md` uses the same JavaScript install/update/remove commands in both the full Ask First policy and selected workflow review ordering. Keeping those arrays duplicated in the scanner and catalog made future reason-code maintenance easier to drift.

## Expected Behavior

- Generated command lists and ordering remain unchanged for existing fixtures.
- `yarn up` is annotated as `dependency_mutation` instead of generic approval metadata.
- npm, pnpm, yarn, and bun install/update/remove commands keep the `dependency_mutation` reason code.
- Future JavaScript package-manager policy edits have one command-family owner for scanner generation and review ordering.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- JavaScript package-manager mutation command ordering stays stable in generated output snapshots.
- JavaScript update/remove commands keep specific dependency-mutation reason metadata.
- Future policy-family changes reuse catalog-owned command arrays instead of reintroducing scanner-local duplicates.
- Self-use policy review can still find the selected package-manager mutation commands near the top of review guidance.

## Failure Signals

- Generated Ask First command ordering changes unexpectedly.
- npm, pnpm, yarn, or bun mutation commands lose the `dependency_mutation` reason code.
- The catalog grows broad ecosystem policy without a measured command-decision need.

## Result

Unjudged.
