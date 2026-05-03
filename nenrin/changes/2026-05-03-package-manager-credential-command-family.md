---
type: nenrin_change
id: package-manager-credential-command-family
date: 2026-05-03
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

# Change: package-manager-credential-command-family

## Changed

- Centralized package-manager credential/session and config forbidden commands in `PolicyReasonCatalog`.
- Made scanner command generation and focused tests consume the same command family used by reason classification.

## Reason

The v0.3 self-use policy review kept the next command on SwiftPM verification and sent Git/GitHub mutation through `command_policy.md`. While reviewing the long policy for credential/session risk, pip/npm/pnpm/yarn/Bundler/Cargo/CocoaPods config and auth commands were correctly labeled as `secret_or_credential_access`, but scanner generation and reason classification still owned overlapping command-family strings separately.

## Expected Behavior

- Generated `command_policy.md` remains behaviorally unchanged for existing package-manager credential/session and config entries.
- Future package-manager credential or config policy additions update one command family instead of drifting between scanner output and reason-code matching.
- Agents continue to refuse these commands as `secret_or_credential_access`.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later package-manager credential/config additions attach to the centralized family without duplicated scanner and reason-catalog lists.
- Self-use policy review still refuses package-manager token, login/logout, identity, and config value-read/mutation commands with credential reasoning.
- Generated output does not churn when internals are refactored.

## Failure Signals

- The command family grows into unrelated dependency mutation or package-publication policy.
- A generated package-manager credential/config command falls back to `unsafe_or_sensitive_command` due to catalog drift.
- The full policy becomes harder to audit because package-manager config, registry publication, and dependency mutation concerns are merged.

## Result

Unjudged.
