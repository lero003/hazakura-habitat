---
type: nenrin_change
id: package-registry-reason-code
date: 2026-05-03
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/PolicyReasonCatalog.swift
  - Tests/HabitatCoreTests/HabitatCoreTests.swift
  - docs/current_status.md
review_after:
  tasks: 3
  days: 7
---

# Change: package-registry-reason-code

## Changed

- Added a `package_registry_mutation` reason family for package publication and registry metadata mutation commands.
- Kept the existing Ask First classification while making `command_policy.md` and `scan_result.json` explain external package-state risk directly.

## Reason

The v0.3 self-use policy review showed that long command policies are only useful when the reason next to a risky command is precise enough to guide the next action. Publication and registry metadata commands were grouped under generic dependency or approval reasons even though their main risk is mutating external package registry state.

## Expected Behavior

- Agents still ask before package publication or registry metadata mutation commands.
- Reviewers can distinguish local dependency mutation from external package registry mutation in generated policy output.
- Future package-registry command additions can use one catalog rule instead of relying on broad mutation-word matching.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later package-registry policy changes attach to the same reason family without new renderer logic.
- Agents explain publish, owner, dist-tag, yank, or trunk commands as external package-state mutations.
- The extra reason code improves policy clarity without bloating `agent_context.md` beyond its line budget.

## Failure Signals

- The new reason code creates noisy short-context summaries without changing decisions.
- Reviewers cannot tell when to use dependency mutation versus package registry mutation.
- Additional registry commands duplicate matching logic outside `PolicyReasonCatalog`.

## Result

Unjudged.
