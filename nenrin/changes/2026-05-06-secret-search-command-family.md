---
type: nenrin_change
id: secret-search-command-family
date: 2026-05-06
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/PolicyReasonCatalog+SecretSearch.swift
  - Sources/HabitatCore/PolicyReasonCatalog.swift
  - Tests/HabitatCoreTests/PackageAndCommandPolicyTests.swift
  - docs/current_status.md
review_after:
  tasks: 3
  days: 7
---

# Change: secret-search-command-family

## Changed

- Centralized secret-bearing broad-search command arrays in `PolicyReasonCatalog`.
- Kept the Ask First reason mapping for recursive `rg`, `grep`, `find ... grep`, and `git grep` search shapes unchanged.
- Added catalog classification coverage so all secret-bearing broad-search commands keep `secret_or_credential_access`.

## Reason

The post-v0.4 self-scan still showed secret-aware search guidance as important command-decision context. The command family was small enough to isolate without changing generated output, and keeping it catalog-owned reduces drift between future search policy edits and existing secret-safety behavior fixtures.

## Expected Behavior

- Generated command lists, reason codes, and ordering remain unchanged for existing fixtures.
- Ordinary read-only search remains available when no secret-bearing files are detected.
- Secret-bearing projects continue to steer broad recursive search toward review or exclusion-aware command shapes.
- Future search-safety edits update one catalog-owned family instead of reintroducing inline command lists.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Secret-bearing search fixtures continue to preserve targeted source inspection while guarding broad recursive search.
- Future `rg`, `grep -R`, `find ... grep`, or `git grep` policy changes reuse `PolicyReasonCatalog+SecretSearch.swift`.
- Generated policy counts stay stable unless a behavior-driven search command addition intentionally changes them.

## Failure Signals

- Broad search becomes over-banned in no-secret repositories.
- Secret-bearing search commands lose `secret_or_credential_access` reason metadata.
- Search policy changes duplicate command lists outside the catalog boundary.

## Result

Unjudged.
