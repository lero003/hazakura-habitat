---
type: nenrin_change
id: ruby-bundler-command-family
date: 2026-05-06
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/PolicyReasonCatalog+RubyPackageManager.swift
  - Sources/HabitatCore/PolicyReasonCatalog.swift
  - Sources/HabitatCore/Scanner.swift
  - Tests/HabitatCoreTests/PackageAndCommandPolicyTests.swift
  - docs/current_status.md
review_after:
  tasks: 3
  days: 7
---

# Change: ruby-bundler-command-family

## Changed

- Centralized Ruby Bundler dependency-mutation Ask First command arrays in `PolicyReasonCatalog`.
- Made scanner Ask First command generation and selected package-manager review ordering consume the same catalog-owned array.
- Added catalog classification coverage so Bundler dependency mutations keep `dependency_mutation`.

## Reason

The post-v0.4 self-scan still showed long command-policy output as active command-decision context. Bundler commands were a small remaining scanner-local package-manager family, which made future Ruby policy edits easier to drift from catalog reason metadata.

## Expected Behavior

- Generated command lists and ordering remain unchanged for existing fixtures.
- `bundle install`, `bundle add`, `bundle update`, `bundle lock`, and `bundle remove` keep `dependency_mutation`.
- Future Bundler policy edits have one command-family owner for scanner generation, review ordering, and reason classification.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Bundler command reasons do not regress into fallback approval metadata.
- Future Ruby package-manager policy changes reuse catalog-owned arrays instead of scanner-local duplicates.
- Generated policy counts stay stable unless a behavior-driven command addition intentionally changes them.

## Failure Signals

- Generated Ask First ordering changes unexpectedly.
- Bundler policy broadens into Ruby environment management without observed command-decision need.
- Ruby package-manager policy becomes inconsistent between selected review ordering and the full command policy.

## Result

Unjudged.
