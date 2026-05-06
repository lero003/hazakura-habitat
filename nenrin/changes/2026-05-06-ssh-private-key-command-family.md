---
type: nenrin_change
id: ssh-private-key-command-family
date: 2026-05-06
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/PolicyReasonCatalog+SshPrivateKey.swift
  - Sources/HabitatCore/Scanner.swift
  - Tests/HabitatCoreTests/PackageAndCommandPolicyTests.swift
review_after:
  tasks: 3
  days: 7
---

# Change: ssh-private-key-command-family

## Changed

- Extracted home SSH private-key Forbidden command shapes into `PolicyReasonCatalog+SshPrivateKey.swift`.
- Routed scanner Forbidden command generation through the catalog-owned SSH private-key family.
- Added catalog classification coverage so every extracted SSH private-key command keeps `secret_or_credential_access`.

## Reason

The scanner still owned a large inline home SSH private-key command list. Keeping it in the catalog reduces drift between generated Forbidden commands and reason-code classification while preserving generated output behavior.

## Expected Behavior

- Agents still avoid reading, copying, uploading, archiving, or loading home SSH private keys.
- Future SSH private-key command edits happen in one catalog boundary instead of inside `Scanner.swift`.
- Generated command counts, ordering, and reason-code meaning remain stable.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later secret-safety edits update the SSH private-key family without touching unrelated scanner policy generation.
- Self-scan keeps the same command counts and short-context Do Not guidance.

## Failure Signals

- Future SSH private-key command additions bypass the catalog.
- Generated policy count or ordering changes unintentionally during a maintainability-only slice.

## Result

Unjudged.
