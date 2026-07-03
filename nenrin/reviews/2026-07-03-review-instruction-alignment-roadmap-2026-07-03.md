---
type: nenrin_review
id: review-instruction-alignment-roadmap-2026-07-03
date: 2026-07-03
related_change: instruction-alignment-roadmap
final_judgment: keep
---

# Review: instruction-alignment-roadmap

## Summary

Keep. Habitat still earns its instruction-alignment scope by turning current
repository facts into bounded command choices and uncertainty instead of
restating project prose or expanding into a general instruction linter.

## Evidence

- A fresh `hazakura-ai-mobile` scan selected the documented executable
  `./scripts/assemble-debug.sh` as ordinary validation while keeping
  `./scripts/device-test.sh` and `./scripts/dev-env-check.sh` scoped to device
  verification and environment preflight. That changed the first validation
  choice without importing the mobile backlog into Habitat.
- The same ai-mobile comparison treated the saved `1.0.0` report versus the
  current `1.1.0` generator as a report-shape change, not as evidence that the
  local environment changed.
- A fresh `hazakura-llm-manager` scan detected multiple documented validation
  workflows, emitted `Open uncertainty`, and kept
  `./script/build_and_run.sh --verify` scoped to launch smoke. It also exposed a
  remaining command-purpose gap: the bare `./script/build_and_run.sh` app-launch
  path is currently classified as ordinary validation and appears before
  `swift test`, despite the repository's SwiftPM-first verification guidance.
  This is bounded evidence to keep the instruction-alignment direction, not a
  reason to claim the generated preference is already correct.
- `DocumentedValidationCommandEvidence` and its focused instruction-alignment,
  CI-presence, and project-local-script tests preserve the same
  fact/uncertainty boundary without broad prose parsing.
- `docs/current_status.md`, `docs/evaluation.md`, and `docs/self_use.md` still
  require the `repo fact -> short annotation -> command decision` loop and
  explicitly accept no-scan sessions when current project guidance is enough.

## Decision

- keep

## Cleanup

- No cleanup in this review. Keep future instruction-alignment work limited to
  measured command-decision gaps, including the observed llm-manager
  app-launch-versus-source-verification classification when that becomes the
  selected slice. Do not broaden this into generic prose linting, plan
  generation, or routine scanning when repository guidance already answers a
  low-risk question.
