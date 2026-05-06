---
type: nenrin_observation
id: behavior-evidence-sanitization-contract-001
date: 2026-05-06
related_changes:
  - secret-bearing-evidence-boundary
impact_judgment: effective
success_tags:
  - behavior-evidence
  - test-coverage
  - secret-safety
failure_tags: []
---

# Observation: behavior-evidence-sanitization-contract-001

## Task

Post-`v0.4.0` self-use checked whether the behavior-evaluation fixture contract matched the documented evidence policy after secret-bearing evidence work.

## Observed Behavior

- `docs/evaluation.md` says JSON fixtures should reject raw local paths, private-key markers, dummy API-key markers, and stored prompt/secret/history or clipboard data.
- The shared fixture test already checked the schema and core sanitization flags, but its text-level rejection list was narrower than the documented evidence policy.

## Success Signals Observed

- The shared behavior-evaluation fixture test now rejects common dummy token prefixes, host-local path prefixes, and raw prompt/secret/history/clipboard field names across every JSON fixture.
- The first overly broad `sk-` check failed because it matched the harmless `risk-aware` metric text; narrowing it to realistic dummy token prefixes kept the contract strict without making evidence prose brittle.

## Failure Signals Observed

- None observed in this slice.

## Impact Judgment

effective

## Next Action

- Keep future behavior evidence additions covered by the shared contract before adding new fixture-specific assertions.
