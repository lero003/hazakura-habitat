---
type: nenrin_change
id: executable-test-annotation-coverage
date: 2026-05-06
status: observing
impact: unknown
related_files:
  - Tests/HabitatCoreTests/PackageAndCommandPolicyTests.swift
  - Tests/HabitatCoreTests/HabitatCoreTests.swift
  - docs/current_status.md
  - docs/roadmap.md
  - docs/self_use.md
review_after:
  tasks: 3
  days: 7
---

# Change: executable-test-annotation-coverage

## Changed

- Marked three intended Swift Testing scenarios with `@Test`: pnpm lockfile selection, older scan-result decoding, and unrelated diagnostic filtering.
- Left scanner behavior, generated Markdown, `scan_result.json`, command ordering, and reason-code behavior unchanged.

## Reason

A test-shaped function without `@Test` is not executable coverage. These scenarios protect command-decision and compatibility behavior that later scanner or report changes could accidentally weaken.

## Expected Behavior

- Future `swift test` runs execute these intended regression scenarios.
- Coverage count changes reflect real executable coverage, not generated-output behavior drift.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later scanner/report edits fail fast if pnpm selection, older JSON compatibility, or unrelated diagnostic filtering regresses.
- Future test moves keep `@Test` annotations visible during review.

## Failure Signals

- More test-shaped functions appear without Swift Testing annotations.
- Restored tests become brittle without protecting command-decision behavior.

## Result

Unjudged.
