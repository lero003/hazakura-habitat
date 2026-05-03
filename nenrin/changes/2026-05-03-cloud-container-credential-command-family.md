---
type: nenrin_change
id: cloud-container-credential-command-family
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

# Change: cloud-container-credential-command-family

## Changed

- Centralized cloud/container credential read and auth-session forbidden commands in `PolicyReasonCatalog`.
- Made scanner command generation and focused tests consume the same command family used by reason classification.

## Reason

The v0.3 self-use policy review kept the next command on SwiftPM verification and sent Git/GitHub mutation through `command_policy.md`. While reading the long policy, cloud/container credential commands such as AWS credential export, gcloud auth token printing, Docker login/context export, and raw kubectl config reads were correctly labeled as `secret_or_credential_access`, but scanner generation and reason classification still owned overlapping command-family strings separately.

## Expected Behavior

- Generated `command_policy.md` remains behaviorally unchanged for existing cloud/container credential entries.
- Future cloud/container credential policy additions update one command family instead of drifting between scanner output and reason-code matching.
- Agents continue to refuse these commands as `secret_or_credential_access`.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later cloud/container credential additions attach to the centralized family without duplicated scanner and reason-catalog lists.
- Self-use policy review still refuses credential exports, auth token prints, Docker credential/session commands, and raw Kubernetes config/token commands with credential reasoning.
- Generated output does not churn when internals are refactored.

## Failure Signals

- The command family grows into broad cloud or container diagnostics unrelated to credential/session safety.
- Prefix matching becomes too narrow and a generated command falls back to `unsafe_or_sensitive_command`.
- The full policy becomes harder to audit because unrelated host-private commands are merged into this family.

## Result

Unjudged.
