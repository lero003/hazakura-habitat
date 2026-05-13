---
type: nenrin_change
id: command-family-model-boundary
date: 2026-05-13
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/PolicyReasonCatalog.swift
  - Sources/HabitatCore/PolicyReasonCatalog+CommandFamily.swift
  - docs/current_status.md
  - docs/roadmap.md
review_after:
  tasks: 3
  days: 7
---

# Change: command-family-model-boundary

## Changed

- Moved `CommandFamily` and `CommandFamilyManifestEntry` into `PolicyReasonCatalog+CommandFamily.swift`.
- Kept reason routing, command families, generated policy output, and tests behavior unchanged.

## Reason

Command-family ownership is now a repeated policy-drift boundary. Keeping the small model types outside the core catalog entrypoint leaves `PolicyReasonCatalog.swift` focused on reason metadata APIs while future family or manifest work starts from a named file boundary.

## Expected Behavior

- Future command-family model changes start in `PolicyReasonCatalog+CommandFamily.swift`.
- `PolicyReasonCatalog.swift` remains focused on public reason lookup and generated finding helpers.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later command-family manifest changes do not expand the core catalog file.
- Catalog behavior remains stable while family ownership continues to evolve.

## Failure Signals

- New model concerns return to `PolicyReasonCatalog.swift`.
- The split encourages speculative catalog abstractions without a command-decision need.

## Result

Unjudged.
