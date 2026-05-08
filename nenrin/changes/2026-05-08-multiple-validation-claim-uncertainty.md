---
type: nenrin_change
id: multiple-validation-claim-uncertainty
date: 2026-05-08
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/DocumentedValidationCommandEvidence.swift
  - Tests/HabitatCoreTests/InstructionAlignmentPolicyTests.swift
  - CHANGELOG.md
  - docs/current_status.md
  - docs/roadmap.md
  - docs/self_use.md
review_after:
  tasks: 3
  days: 7
---

# Change: multiple-validation-claim-uncertainty

## Changed

- Changed documented validation-command evidence so multiple instruction files that mention different validation workflows emit bounded `Open uncertainty`.
- Added an instruction-alignment test proving conflicting SwiftPM and npm validation claims do not silently collapse to the first claim.

## Reason

The post-`v0.5` handoff named conflicting validation claims as the next small instruction-alignment risk. Trusting `claims.first` is tidy but too confident when allowlisted instruction files disagree. `Open uncertainty` is the safer command-decision shape because it tells an agent to verify the intended validation path before following one documented command.

## Expected Behavior

- Agents pause on conflicting documented validation workflows instead of treating one instruction file as authoritative.
- Agents can still prefer the repository-supported validation command for ordinary local validation when repo facts support it.
- Raw instruction prose stays out of generated artifacts.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Later instruction-alignment slices keep uncertainty bounded instead of becoming broad prose linting.
- Agents choose `swift test` for ordinary local validation while noticing that instruction files disagree.

## Failure Signals

- Agents ignore `Open uncertainty` and blindly run a stale documented command.
- The uncertainty wording becomes too broad to affect the next command.

## Result

Unjudged.
