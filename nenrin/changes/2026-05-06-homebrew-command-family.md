---
type: nenrin_change
id: homebrew-command-family
date: 2026-05-06
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/PolicyReasonCatalog+Homebrew.swift
  - Sources/HabitatCore/PolicyReasonCatalog.swift
  - Sources/HabitatCore/Scanner.swift
  - Tests/HabitatCoreTests/PackageAndCommandPolicyTests.swift
  - docs/current_status.md
review_after:
  tasks: 3
  days: 7
---

# Change: homebrew-command-family

## Changed

- Centralized Homebrew direct Ask First and Bundle review command arrays in `PolicyReasonCatalog`.
- Made scanner Ask First command generation and selected Homebrew review ordering consume catalog-owned arrays.
- Added catalog classification coverage so Homebrew dependency mutations and generic approval commands keep their current reason codes.

## Reason

The post-v0.4 self-scan still showed long command-policy output as active command-decision context. Homebrew was a small remaining scanner-local package-manager family, which made future Brewfile or Homebrew policy edits easier to drift from catalog-owned review ordering.

## Expected Behavior

- Generated command lists and ordering remain unchanged for existing fixtures.
- `brew install`, `brew update`, and `brew bundle install` keep `dependency_mutation`.
- `brew cleanup`, `brew autoremove`, `brew tap`, `brew tap-new`, `brew bundle`, `brew bundle cleanup`, and `brew bundle dump` keep generic approval classification.
- Future Homebrew policy edits have one command-family owner for scanner generation and review ordering.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Homebrew command reasons do not regress into unintended dependency-mutation or fallback metadata.
- Future Brewfile policy changes reuse catalog-owned arrays instead of scanner-local duplicates.
- Generated policy counts stay stable unless a behavior-driven command addition intentionally changes them.

## Failure Signals

- Generated Ask First ordering changes unexpectedly.
- Homebrew policy broadens into full machine inventory or `brew doctor`-style diagnostics without observed command-decision need.
- Homebrew Bundle guidance becomes inconsistent between selected review ordering and the full command policy.

## Result

Unjudged.
