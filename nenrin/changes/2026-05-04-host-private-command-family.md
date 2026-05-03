---
type: nenrin_change
id: host-private-command-family
date: 2026-05-04
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/PolicyReasonCatalog.swift
  - Sources/HabitatCore/Scanner.swift
  - Tests/HabitatCoreTests/HabitatCoreTests.swift
  - docs/current_status.md
review_after:
  tasks: 3
  days: 7
---

# Change: host-private-command-family

## Changed

- Centralized environment dump, clipboard read, shell-history read, browser-profile, and local-mail forbidden commands in `PolicyReasonCatalog`.
- Made scanner forbidden-command generation consume the same command family used by `host_private_data` reason classification.
- Added test coverage that every generated host-private command receives `host_private_data` instead of generic unsafe-command metadata.

## Reason

The v0.3 self-use context kept host-private actions visible in the short Do Not list, but policy review showed the long forbidden list still depended on scanner-owned host-private command literals while reason matching only recognized a few sentinel entries. That left ordinary generated examples such as `pbpaste`, shell-history file reads, or browser/mail inspection vulnerable to generic reason-code fallback.

## Expected Behavior

- Generated short-context host-private guidance remains unchanged.
- Long `command_policy.md` entries for host-private commands explain `host_private_data` consistently.
- Future host-private command additions update one command family instead of drifting between scanner output and reason-code matching.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Self-use policy review can identify clipboard, history, browser, mail, and environment dumps as local host-private data risks without reading extra docs.
- Generated output changes only reason annotations for existing host-private commands.
- Later host-private policy additions do not duplicate command literals across scanner generation and reason matching.

## Failure Signals

- Host-private command classification becomes too broad and absorbs secret-file or credential commands.
- Agents treat all project-local source inspection as host-private host data.
- The centralized family grows into unrelated package-manager or cloud credential policy.

## Result

Unjudged.
