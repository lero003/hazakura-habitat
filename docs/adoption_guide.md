# AI Agent Adoption Guide

Status: operational
Scope: Partial adoption of Hazakura Habitat by AI coding agents and harnesses
Authority: medium
Last reviewed: 2026-05-15

Hazakura Habitat is meant to be useful when an AI coding agent reads a
repository and needs safer command context before work starts.

This guide is for agents, harness authors, and maintainers deciding how much
Habitat to adopt. It is not a replacement for `README.md`, `AGENTS.md`,
roadmaps, changelogs, or project-specific development docs.

## Adoption Levels

| Level | Use when | Minimum action |
| --- | --- | --- |
| 0. No adoption | Existing project guidance already gives enough current command context for a low-risk task. | Do nothing. |
| 1. Read-only reference | An agent needs the Habitat pattern but cannot run the CLI yet. | Read `agent_context.md` / `command_policy.md` examples and apply the same conservative decision style manually. |
| 2. One-time preflight | A repository is unfamiliar, risky, or has unclear tool/package-manager signals. | Run `habitat-scan scan --project <repo> --output ./habitat-report`, then read `agent_context.md` first. |
| 3. Agent skill | Agents repeatedly work in the repository. | Install or vendor the bundled skill and let it decide when a scan is worth running. |
| 4. Scripted consumption | Automation or local scripts need a verified artifact. | Use `--stdout` or the checksum-first helper scripts instead of inventing a new installer path. |
| 5. Feedback loop | Repeated Habitat output changes later command choices. | Record behavior-level evidence in docs, examples, tests, or Nenrin; keep the loop at `repo fact -> short annotation -> command decision -> observed effect`. |

Start at the lowest level that changes the next command decision. Full adoption
is not the goal.

## Agent Instructions To Copy

Use this when adding Habitat to `AGENTS.md`, `CLAUDE.md`, a skill, or a harness
prompt:

```md
Use Hazakura Habitat as advisory pre-execution context for AI coding work.

Run Habitat before substantial implementation, dependency or lockfile changes,
Git/GitHub mutations, unfamiliar-repository onboarding, or secret-adjacent work.
Read `habitat-report/agent_context.md` first.
Consult `habitat-report/command_policy.md` before risky, mutating, dependency,
Git/GitHub, archive, copy, sync, cleanup, or secret-adjacent commands.

Treat Habitat output as advisory context. It does not approve, deny, execute,
sandbox, or enforce commands.
```

## Do Not

- Do not replace `README.md`, `AGENTS.md`, changelogs, roadmaps, or local
  development docs with Habitat output.
- Do not treat `agent_context.md` as the full approval policy; use
  `command_policy.md` before risky commands.
- Do not use Habitat as a task planner.
- Do not copy raw chat logs, private reasoning, unresolved speculation, or
  secret values into Habitat docs, examples, or behavior fixtures.
- Do not treat a saved report as current after important project files changed;
  refresh or compare freshness metadata first.
- Do not install globally, edit shell startup files, or run remote installer
  scripts unless the user explicitly authorized that class of mutation.

## Expected Benefit

Adoption is useful when it helps an AI agent:

- choose the repository's actual tool or package-manager path
- avoid risky default installs, updates, or global mutations
- ask before dependency, lockfile, Git/GitHub, or release-artifact changes
- avoid reading, copying, archiving, or loading secret-bearing paths
- notice when written guidance and current repository facts do not align

If Habitat output does not change command choice, verification order, or risk
handling, keep the adoption level lower.
