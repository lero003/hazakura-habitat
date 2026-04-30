# Positioning

Last reviewed: 2026-05-01.

This document is a working market map, not a timeless competitive analysis. AI coding agents, permission systems, sandboxes, and enterprise AI security products are changing quickly. Keep this document focused on Habitat's own position, not on maintaining a live catalog of competitors.

## Summary

Hazakura Habitat's closest position is:

> An agent-neutral pre-execution context generator for AI coding agents.

It is not an AI coding agent, sandbox, permission system, or runtime security monitor. It does not execute, approve, or block commands.

Habitat generates short, conservative, project-derived context before an AI coding agent starts work:

- which project tools to prefer
- which commands should require confirmation
- which commands should be avoided
- which project signals make command choice ambiguous
- which secret-bearing files exist without reading their values

The useful metaphor is:

> Habitat is a map before the agent walks, not a fence around the agent.

## Ecosystem Intent

Habitat should be open in spirit as well as source.

If other projects copy the idea, reimplement the mechanism, or build better agent-facing context layers, that supports the mission. The point is not to protect a narrow product category. The point is to normalize better pre-execution context for AI-led development.

## Competitive Layers

| Layer | Examples | Relationship to Habitat |
| --- | --- | --- |
| AI coding agents | Codex CLI, Claude Code, OpenCode, Cline, Goose | Potential consumers, not direct replacements |
| Permission and approval systems | Codex approvals, Claude permissions, OpenCode permissions | Adjacent execution-time controls |
| Sandboxes and dev environments | Codex sandbox, devcontainers, CDEs | Complementary safety boundaries |
| Runtime security and governance | Sysdig, Zenity, enterprise security platforms | Enterprise monitoring and enforcement, not Habitat's lane |

## Role Boundaries

AI coding agents:

```text
Do the work.
```

Permission systems:

```text
Decide whether a requested action may run, should ask, or should be blocked.
```

Sandboxes and devcontainers:

```text
Limit the blast radius if a command runs.
```

Runtime security systems:

```text
Observe, detect, govern, and sometimes block behavior across an organization.
```

Hazakura Habitat:

```text
Before any work starts, generate project-specific context that helps the agent choose a better next command.
```

## Differentiation

### Agent-Neutral

Habitat should not be tied to one agent runtime.

```text
Generate once, use with any agent.
```

### Pre-Execution

Habitat improves context before the agent asks to run a command. It should not claim to enforce runtime behavior.

```text
Before the agent asks to run a command, give it better context.
```

### Project-Derived

Habitat uses project-local signals rather than broad global inventory:

- package files
- lockfiles
- runtime hints
- selected package manager evidence
- secret-bearing file presence
- previous-scan command-changing deltas

### Advisory, Not Enforcement

Habitat produces conservative context. It is not a sandbox, permission gate, or security monitor.

### Short Output Contract

Habitat is valuable only if agents can actually use its output.

```text
Command decisions over environment inventory.
```

## Adjacent Tools

### Codex CLI

Codex has sandbox and approval concepts that govern what can be done at runtime. Habitat should complement Codex by generating `agent_context.md` and `command_policy.md` that Codex or a user can read before work begins.

Do not position Habitat as a Codex replacement or a safer agent execution runtime.

### Claude Code

Claude Code permissions can allow, ask, or deny tool usage. Habitat can provide project-derived context that helps a user decide what should be allowed, asked, or denied for a repository.

Do not position Habitat as a replacement for Claude Code permissions.

### OpenCode

OpenCode exposes explicit permission configuration, including allow, ask, and deny decisions. Habitat may eventually be a good source of context for OpenCode configuration, but should not generate agent-specific permission files until the advisory output contract is mature.

### Cline, Goose, and Other Agents

These are agent surfaces that may benefit from Habitat output. Habitat should avoid becoming an agent itself.

### Sandboxes and Devcontainers

Sandboxes reduce damage if a command runs. Habitat helps decide which command should be considered in the first place.

Use Habitat alongside sandboxing, not instead of sandboxing.

### Enterprise Runtime Security

Enterprise security platforms increasingly monitor AI coding assistant behavior, sensitive file access, MCP usage, and runtime command execution. Habitat should not compete with that governance layer.

Habitat's scope is local, read-only, and pre-execution.

## Main Strategic Risk

The biggest competitive risk is not a standalone tool doing exactly what Habitat does.

The bigger risk is that major AI coding agents add built-in project-aware command policy generation:

```text
agent reads project files
agent infers package manager and risky commands
agent configures its own Allow / Ask / Deny policy
```

Habitat can remain useful by staying:

- agent-neutral
- local-first
- read-only
- auditable
- project-derived
- short
- easy to inspect as Markdown and JSON

## Dangerous Positioning

Avoid these claims:

- safer agent execution environment
- complete local environment dashboard
- automatic permission generator
- runtime command controller
- enterprise security monitor
- secret scanner

Prefer these claims:

- agent-neutral context layer
- pre-execution command-decision context
- conservative advisory policy
- project-derived guidance
- short AI-facing output

## README Positioning Text

Use this short version in public-facing material:

```markdown
Hazakura Habitat is not an AI coding agent, sandbox, or runtime security monitor.

It does not execute, approve, or block commands.

Instead, it generates short, conservative, project-derived context before an AI coding agent starts working. The goal is to help agents choose better commands, avoid risky defaults, and ask before mutating dependencies or touching sensitive files.

Habitat is designed to complement tools such as Codex CLI, Claude Code, OpenCode, Cline, Goose, and sandboxed development environments.
```

## Reference Points

These references are useful context for the current market map. They should not turn this document into a live competitor tracker.

- [Codex agent approvals and security](https://developers.openai.com/codex/agent-approvals-security)
- [Codex sandboxing](https://developers.openai.com/codex/concepts/sandboxing)
- [Claude Code permissions](https://code.claude.com/docs/en/permissions)
- [OpenCode permissions](https://opencode.ai/docs/permissions/)
- [Cline](https://cline.bot/)
- [Goose docs](https://goose-docs.ai/)
- [Sysdig runtime security for AI coding agents](https://www.sysdig.com/blog/runtime-security-for-ai-coding-agents-protecting-ai-assisted-development)
- [Zenity securing agentic coding assistants](https://zenity.io/blog/product/from-ide-to-cli-securing-agentic-coding-assistants)
