---
type: nenrin_change
id: project-environment-command-family
date: 2026-05-06
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/PolicyReasonCatalog+ProjectEnvironment.swift
  - Sources/HabitatCore/Scanner.swift
  - Sources/HabitatCore/ReportWriter.swift
  - Tests/HabitatCoreTests/PackageAndCommandPolicyTests.swift
review_after:
  tasks: 3
  days: 7
---

# Change: project-environment-command-family

## Changed

- Extracted virtual-environment creation/deletion and version-manager file mutation Ask First commands into `PolicyReasonCatalog+ProjectEnvironment.swift`.
- Routed scanner Ask First generation and report prioritization through the catalog-owned project-environment families.
- Added catalog classification coverage so virtual-environment commands keep generic approval and version-manager mutation keeps `version_manager_mutation`.

## Reason

The scanner and report writer still referenced project-environment guard strings directly. Keeping those strings in the catalog reduces drift between generated Ask First commands, review-first prioritization, and reason-code classification while preserving generated output behavior.

## Expected Behavior

- Agents still ask before creating or deleting virtual environments.
- Agents still ask before modifying version-manager files.
- Future project-environment guard edits happen in one catalog boundary instead of scattering across scanner, renderer, and classifier code.
- Generated command counts, ordering, and reason-code meaning remain stable.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later project-environment policy edits update the catalog family without touching unrelated scanner policy generation.
- Self-scan keeps the same command counts and short-context Ask First guidance.

## Failure Signals

- Future virtual-environment or version-manager command additions bypass the catalog.
- Generated policy count or ordering changes unintentionally during a maintainability-only slice.

## Result

Unjudged.
