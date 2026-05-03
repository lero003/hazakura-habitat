---
type: nenrin_change
id: cli-auth-credential-command-family
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

# Change: cli-auth-credential-command-family

## Changed

- Centralized CLI auth-session and credential-store forbidden commands in `PolicyReasonCatalog`.
- Made scanner command generation consume the same command family used by reason classification.

## Reason

The v0.3 self-use policy review kept the next command on SwiftPM validation and made credential/session refusal reasons visible in the full command policy. While using that policy, `gh auth`, Git credential-helper, and macOS `security` commands still had duplicated command-family ownership between scanner generation and reason classification.

## Expected Behavior

- Generated `command_policy.md` remains behaviorally unchanged for existing credential-store and CLI auth entries.
- Future `gh auth`, Git credential-helper, or macOS `security` policy additions update one command family instead of drifting between scanner output and reason-code matching.
- Agents continue to explain these commands as `secret_or_credential_access`.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later credential/session policy changes attach to the centralized family without duplicated scanner and reason-catalog lists.
- Self-use policy review still refuses auth token, credential-helper, and Keychain dump commands with credential/session reasoning.
- Generated output does not churn when internals are refactored.

## Failure Signals

- Prefix matching becomes too narrow and misses newly generated auth/session commands.
- The centralized family grows into unrelated host-private or package-manager config policy.
- A generated forbidden command falls back to `unsafe_or_sensitive_command` due to catalog drift.

## Result

Unjudged.
