---
type: nenrin_change
id: policy-index-conditional-section-contract
date: 2026-05-08
status: observing
impact: unknown
related_files:
  - Tests/HabitatCoreTests/PolicyOutputContractTests.swift
  - CHANGELOG.md
  - docs/current_status.md
  - docs/roadmap.md
  - docs/self_use.md
review_after:
  tasks: 3
  days: 7
---

# Change: policy-index-conditional-section-contract

## Changed

- Added an output-contract test proving `command_policy.md` `Policy Index` omits conditional entries when `Review First`, `Reason Codes`, and secret-bearing guidance sections are not rendered.
- Documented the contract as part of the existing `PolicyOutputContractTests` ownership boundary.

## Reason

Agents use the compact policy index as navigation before deciding whether to inspect the long policy. If the index points at omitted headings, a Markdown-only agent or machine reader can waste attention on non-existent sections and weaken trust in the rest of the policy contract.

## Expected Behavior

- Future command-policy rendering changes fail fast when absent conditional sections remain advertised in the index.
- The index stays a precise navigation summary rather than a fixed table of possible sections.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later conditional policy sections update rendering, metadata, and index tests together.
- Agents can treat `Policy Index` as a truthful list of rendered sections.

## Failure Signals

- The policy index intentionally becomes a schema-like list of possible sections instead of rendered-section navigation.
- Conditional sections are always rendered with explicit empty-state text.

## Result

Unjudged.
