# Agent Contract

## Purpose

This document defines the contract between Hazakura Habitat and AI coding agents.

The generated artifacts should make the agent's next action safer and more specific.

## Primary Artifact: agent_context.md

`agent_context.md` is the most important human-readable output.

It should be short, direct, and action-oriented.

Required sections:

```markdown
# Agent Context

## Freshness
- Scanned at:
- Project:

## Use
- ...

## Avoid
- ...

## Ask First
- ...

## Mismatches
- ...

## Notes
- ...
```

Guidelines:

- Prefer imperative guidance over narrative explanation.
- Keep it short enough to paste into an AI prompt.
- Mention only details that can affect project work.
- Do not dump full package inventories here.
- Include scan freshness because environment data becomes stale quickly.

Example:

```markdown
## Use
- Use `pnpm` because `pnpm-lock.yaml` exists.
- Use Node from `/opt/homebrew/bin/node`.

## Avoid
- Do not run `npm install` unless the user approves switching package managers.
- Do not run `brew upgrade`.

## Ask First
- Active Node is `v22`, but `.nvmrc` requests `v20`.
```

## Primary Artifact: command_policy.md

`command_policy.md` tells the agent how to classify commands.

Required sections:

```markdown
# Command Policy

## Allowed

## Ask First

## Forbidden

## If Dependency Installation Seems Necessary
```

Default classifications:

Allowed:

- read-only project inspection
- test commands for the selected project
- build commands for the selected project
- package manager commands that do not install, update, delete, or mutate global state

Ask First:

- `brew install`
- `pip install`
- `npm install`
- `pnpm install`
- `yarn install`
- `bundle install`
- creating or deleting virtual environments
- modifying lockfiles
- modifying version manager files

Forbidden in MVP-generated policy:

- `sudo`
- `brew upgrade`
- `brew uninstall`
- `npm install -g`
- global `pip install`
- destructive file deletion outside the selected project
- reading secret values

## Machine Artifact: scan_result.json

`scan_result.json` is the stable source of truth.

Top-level shape:

```json
{
  "schemaVersion": "0.1",
  "scannedAt": "2026-04-25T00:00:00Z",
  "projectPath": "/path/to/project",
  "system": {},
  "commands": [],
  "project": {},
  "tools": {},
  "policy": {},
  "warnings": [],
  "diagnostics": []
}
```

Compatibility:

- Add fields freely during `0.x`.
- Do not rename or remove fields without documenting a schema change.
- Generate Markdown from this JSON when possible.

## Secondary Artifact: environment_report.md

`environment_report.md` is the longer report for audit and debugging.

It can include:

- command resolution table
- detected project files
- tool versions
- scanner diagnostics
- warnings
- privacy note

It should not compete with `agent_context.md`. If a detail is critical for AI behavior, put it in `agent_context.md` first.

## AI Usability Test

Before accepting a report format, ask:

- Can an agent choose the likely package manager?
- Can an agent identify commands that need approval?
- Can an agent notice version mismatches?
- Can an agent avoid global mutation?
- Can an agent ignore irrelevant global inventory?

If not, the artifact is not useful enough.

