---
type: nenrin_change
id: host-environment-command-family
date: 2026-05-06
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/PolicyReasonCatalog+HostEnvironment.swift
  - Sources/HabitatCore/PolicyReasonCatalog.swift
  - Sources/HabitatCore/Scanner.swift
  - Tests/HabitatCoreTests/PackageAndCommandPolicyTests.swift
  - docs/current_status.md
review_after:
  tasks: 3
  days: 7
---

# Change: host-environment-command-family

## Changed

- Centralized remote-script execution and global environment mutation Forbidden command arrays in `PolicyReasonCatalog`.
- Made scanner Forbidden command generation consume those catalog-owned arrays without changing intended generated policy output.
- Added catalog classification coverage so remote-script execution keeps `remote_script_execution` and host-level install, upgrade, service, and global tool mutations keep `global_environment_mutation`.

## Reason

The post-v0.4 self-scan still showed host-level safety commands as part of the long generated command-decision contract. Those command lists were scanner-local while their reason metadata lived in the catalog, which made future host-environment safety edits easier to drift.

## Expected Behavior

- Generated command lists and ordering remain unchanged for existing fixtures.
- `curl | sh` / `wget | sh` style commands keep `remote_script_execution`.
- Homebrew host-state mutation, global package installs, pipx, uv tool, gem, Go, and Cargo host mutations keep `global_environment_mutation`.
- Future host-environment policy edits have one command-family owner for scanner generation and reason classification.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Remote-script and global host-mutation command reasons do not regress into fallback metadata.
- Future host-environment safety changes reuse catalog-owned arrays instead of reintroducing scanner-local duplicates.
- Generated policy counts stay stable unless a behavior-driven command addition intentionally changes them.

## Failure Signals

- Generated Forbidden command ordering changes unexpectedly.
- Global environment mutation wording expands into broad host inventory or repair guidance.
- Remote script policy starts suggesting installer flows instead of preserving advisory refusal.

## Result

Unjudged.
