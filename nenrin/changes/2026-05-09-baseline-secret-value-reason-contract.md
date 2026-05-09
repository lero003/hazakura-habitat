---
type: nenrin_change
id: baseline-secret-value-reason-contract
date: 2026-05-09
status: observing
impact: unknown
related_files:
  - Tests/HabitatCoreTests/PolicyReasonCatalogTests.swift
  - docs/current_status.md
  - docs/roadmap.md
review_after:
  tasks: 3
  days: 7
---

# Change: baseline-secret-value-reason-contract

## Changed

- Added executable coverage that baseline Forbidden secret-value guard wording stays in baseline policy and keeps secret_or_credential_access reason metadata.

## Reason

These short generated policy entries affect how agents interpret secret-value bans; a wording drift should not silently fall back to generic unsafe-command metadata.

## Expected Behavior

- Future baseline secret-value guard edits preserve credential-specific command-reason metadata or consciously update the contract.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- TBD

## Failure Signals

- TBD

## Result

Unjudged.
