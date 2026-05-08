---
type: nenrin_change
id: review-first-markdown-sync-contract
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

# Change: review-first-markdown-sync-contract

## Changed

- Added an output-contract test proving `command_policy.md` `Review First` lines match serialized `policy.reviewFirstCommandReasons` entries exactly.
- Documented the contract as part of the existing PolicyOutputContractTests ownership boundary.

## Reason

Agents can either read the short `Review First` Markdown block or consume `scan_result.json` metadata. If those two surfaces drift, a future agent may review one approval reason in Markdown while tooling reports another.

## Expected Behavior

- Future Review First rendering or metadata changes fail fast when the Markdown and JSON views diverge.
- Output-contract hardening stays in the generated-output contract suite without changing representative examples.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later Review First edits update JSON and Markdown behavior together.
- No extra generated-output churn is needed for metadata-only contract hardening.

## Failure Signals

- Review First intentionally gains Markdown-only presentation detail that should not be serialized.
- The JSON schema for Review First is intentionally decoupled from rendered policy text.

## Result

Unjudged.
