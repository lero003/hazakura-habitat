# Nenrin Ledger

This directory is an improvement observation ledger for the AI agent working environment.

Use this ledger for changes to agent-facing artifacts only when the change
should affect a later command decision, report-freshness judgment, pruning
choice, or keep/remove/merge/narrow review. It is intentionally visible but
sparse after `v1.0.0`.

## Workflow

1. Create a change record when an agent-facing artifact changes future agent
   behavior, not for every routine edit.
2. Create observation records after related work only when the observation adds
   behavior-level evidence.
3. Review whether the improvement should be kept, removed, merged, narrowed,
   moved to a skill, moved to a handoff, or kept observing.

## What Nenrin Is Not

- Not prompt eval.
- Not production observability.
- Not a benchmark suite.
- Not an agent runtime.

It is a lightweight improvement observation ledger.

It is not a changelog mirror or a Habitat work selector.

## Frontmatter

Nenrin frontmatter supports a small YAML-like subset: scalar values, nested mappings, and simple lists. Keep values boring so agents and the CLI can both read them.

Observation records may include optional `success_tags` and `failure_tags` to reduce wording drift when tracking recurring signals.

## Future Review Flow

Review records include `final_judgment`. A later CLI version should use that field to prompt updates to the related change's `status` and `impact`.
