---
type: nenrin_change
id: secret-bearing-evidence-boundary
date: 2026-05-06
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/SecretBearingEvidence.swift
  - Sources/HabitatCore/SecretFileDetector.swift
  - Sources/HabitatCore/ReportWriter.swift
  - Tests/HabitatCoreTests/SecretFileDetectionTests.swift
  - docs/current_status.md
  - docs/roadmap.md
  - docs/self_use.md
review_after:
  tasks: 3
  days: 7
---

# Change: secret-bearing-evidence-boundary

## Changed

- Added `SecretBearingEvidence` as a filename-only value for detected secret-bearing paths and grouped environment, package-manager auth, cloud/container credential, and private-key path signals.
- Routed `SecretFileDetector` and `ReportWriter` through the evidence value while preserving generated Markdown wording, reason codes, command ordering, `scan_result.json`, and the public `ReportWriter` API.
- Kept renderer-specific search-exclusion wording and command-shape formatting in `ReportWriter` instead of turning the evidence value into a broad normalized-output layer.
- Added focused test coverage for the evidence boundary.

## Reason

The post-`v0.4.0` secret-bearing search observations showed a real command-decision boundary: broad project search must change shape when secret-bearing files exist, while targeted non-secret source inspection must remain available. A small evidence value gives that boundary one owner without building a generic `NormalizedEvidence` layer up front.

## Expected Behavior

- Future secret-bearing search/copy/archive work starts from sanitized filename-only evidence.
- Agents still receive the same generated guidance for broad search exclusions and targeted source inspection.
- Future `v0.5` work stays local to observed command-changing signals unless another measured case justifies a new evidence shape.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Secret-bearing fixtures continue to pass without generated-output drift.
- New secret-bearing file categories can update the evidence boundary without duplicating filename matching across scanner and renderer code.
- Agents continue to reshape broad search while preserving direct non-secret source/test inspection.

## Failure Signals

- The evidence value starts carrying renderer wording, broad policy interpretation, raw file contents, or non-secret project prose.
- Future work expands into a generic evidence protocol without a measured command-decision problem.
- Generated output changes unintentionally after evidence-only refactors.

## Result

Unjudged.
