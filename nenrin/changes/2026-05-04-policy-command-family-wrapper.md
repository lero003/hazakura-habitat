---
type: nenrin_change
id: policy-command-family-wrapper
date: 2026-05-04
status: reviewed
impact: effective
related_files:
  - Sources/HabitatCore/PolicyReasonCatalog.swift
  - docs/current_status.md
review_after:
  tasks: 3
  days: 7
---

# Change: policy-command-family-wrapper

## Changed

- Added a small `CommandFamily` wrapper inside `PolicyReasonCatalog`.
- Kept scanner-facing command arrays available while making reason classifiers consume the same wrapped command families for membership checks.
- Converted the existing local Git, GitHub, package registry, ephemeral package execution, credential, cloud/container, and host-private families to the wrapper without changing generated output.

## Reason

The v0.3 self-use report kept directing the agent to inspect long policy sections before Git, credential, host-private, or package mutation commands. Those decisions depend on command lists and reason-code classifiers staying aligned. Several policy families still used paired command arrays and separately built sets, which made future v0.4 reason-code hardening easier to drift even when behavior stayed correct today.

## Expected Behavior

- Generated `agent_context.md`, `command_policy.md`, and `scan_result.json` remain unchanged for existing fixtures.
- Policy reason classifiers keep using the exact command families rendered by generated policy.
- Future policy-family additions have one structural pattern for array output and fast reason lookup.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- New command families do not duplicate array/set plumbing.
- Existing generated-output snapshots stay stable after policy-family refactors.
- Self-use policy review can still find the relevant reason code at the command line.

## Failure Signals

- The wrapper hides which command families are exported for scanner generation.
- Command-family initialization order causes generated command lists to change.
- Future contributors add new ad hoc command sets instead of using the wrapper.

## Result

Reviewed on 2026-05-04: keep. The evidence shows the wrapper pattern changed later cleanup choices by moving duplicated command-decision data toward one-owner policy catalog structures without changing generated output.
