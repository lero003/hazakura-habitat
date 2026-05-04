---
type: nenrin_change
id: maintainability-roadmap-guardrails
date: 2026-05-05
status: observing
impact: unknown
related_files:
  - docs/current_status.md
  - docs/development_loop.md
  - docs/roadmap.md
  - CHANGELOG.md
review_after:
  tasks: 3
  days: 7
---

# Change: maintainability-roadmap-guardrails

## Changed

- Added near-term maintainability warning lights for `Scanner.swift`, `PolicyReasonCatalog.swift`, and the monolithic Habitat core test file.
- Added `v0.5` entry criteria so Evidence and Instruction Alignment work starts from command-changing, fixture-able cases instead of broad architecture.
- Added roadmap guidance to pair adjacent feature work with targeted scanner, catalog, or test decomposition.
- Updated the post-`v0.4` automation handoff to keep `v0.5` tied to evidence, instruction alignment, and adjacent maintainability needs.
- Clarified that read-only MCP may move earlier only if file-based consumption becomes a measured blocker.
- Added Linux feasibility and distribution-trust notes without changing the current macOS-first support promise.

## Reason

External project feedback identified that Habitat's biggest near-term risk is not concept clarity, but maintainability and adoption timing: large single files, curated command catalogs, self-use bias, unclear `v0.5` start conditions, deferred MCP/distribution work, and no Linux support guarantee. The response should narrow future work, not trigger an immediate broad refactor.

## Expected Behavior

- Future policy or evidence slices include a small maintainability payoff when they touch adjacent code.
- `v0.5` work starts only from a measured command-decision case with fixture coverage.
- Ecosystem priorities are not justified only by Habitat self-use.
- MCP and Linux work remain scoped as feasibility or read-only integration until behavior evidence shows they are the bottleneck.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- The next feature slice splits one scanner responsibility, catalog family, or test scenario group while preserving generated output.
- Review discussions can point to explicit `v0.5` entry criteria instead of debating abstract NormalizedEvidence scope.
- At least one non-Habitat fixture or trace informs future ecosystem priority.
- Distribution or MCP changes remain advisory and read-only.

## Failure Signals

- New command families are added while `Scanner.swift`, `PolicyReasonCatalog.swift`, and the test file keep growing without local boundaries.
- `v0.5` becomes a broad evidence framework before a command-changing case is proven.
- Linux, MCP, plugin, or distribution work expands the product surface before the advisory CLI contract is stable.
- Self-use evidence alone is used to justify broad ecosystem priorities.

## Result

Unjudged.
