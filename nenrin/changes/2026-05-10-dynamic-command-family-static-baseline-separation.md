# dynamic-command-family-static-baseline-separation

## Status

observing

## Date

2026-05-10

## Context

The catalog now distinguishes static baseline policy families from dynamic Ask First command families that are added only when current repository facts justify them, such as selected SwiftPM dependency resolution or secret-bearing broad search.

## Change

- Added a `BaselineCommandCatalogTests` contract requiring dynamic Ask First command-family commands to stay out of static baseline Ask First / Forbidden policy.
- Updated status and roadmap notes to make the dynamic-versus-static boundary explicit.
- Renamed the manifest source to `dynamicAskFirst` so future dynamic Forbidden policy would need its own explicit path.
- Preserved generated policy output and command ordering.

## Expected Effect

Future catalog edits should not quietly move project-fact-dependent guidance into always-rendered baseline policy. Agents should keep seeing dynamic Ask First guidance only when the scan observes the relevant command-decision signal.

## Review Trigger

- A future dynamic family is added.
- `command_policy.md` starts showing selected-workflow or secret-search guidance when the project facts do not support it.

## Observation

Pending.
