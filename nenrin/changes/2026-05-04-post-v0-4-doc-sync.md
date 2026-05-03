---
type: nenrin_change
id: post-v0-4-doc-sync
date: 2026-05-04
status: observing
impact: unknown
related_files:
  - README.md
  - CHANGELOG.md
  - docs/current_status.md
  - docs/development_loop.md
  - docs/roadmap.md
review_after:
  tasks: 3
  days: 7
---

# Change: post-v0-4-doc-sync

## Changed

- Updated post-release docs from `v0.4` release preparation to post-`v0.4` self-use observation.
- Clarified that `v0.5` Evidence Normalization should start from observed `v0.4` behavior instead of a broad upfront pipeline.
- Clarified release-install guidance for full `SHA256SUMS` verification across all generated release assets.

## Reason

`v0.4.0 Developer Preview` is now public. Future agents should not keep optimizing for the already-shipped Policy Finding Foundation or assume that `NormalizedEvidence` must be designed broadly before more self-use evidence exists. The release also exposed a small documentation lesson: checksum verification is clearest when users download all generated release assets before running `shasum -c SHA256SUMS`.

## Expected Behavior

- Future work uses the published `v0.4.0` artifacts during real self-use before starting broad `v0.5` architecture.
- Agents look for concrete scanner facts that should become normalized evidence before feeding `PolicyFinding`.
- Users can follow README release verification without being surprised by multi-asset checksums.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- The next self-use slice references post-`v0.4` observation rather than pre-release `v0.4` hardening.
- Evidence-normalization work begins from one measured command-decision problem.
- Release-install questions do not recur around `SHA256SUMS` asset coverage.

## Failure Signals

- Agents continue to treat `v0.4` as unfinished release-prep work.
- `v0.5` work starts with a broad generic evidence layer before self-use proves the need.
- README checksum guidance still causes users to download only one asset and see a failed verification.

## Result

Unjudged.
