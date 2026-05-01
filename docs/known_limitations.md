# Known Limitations

Hazakura Habitat is currently a `v0.1.0 Developer Preview` candidate.

The current goal is not broad coverage. The goal is useful, conservative, project-derived command context for AI coding agents.

## Preview Scope

- macOS-first.
- SwiftPM CLI first.
- Advisory context only.
- Read-only scanning only.
- Output optimized for AI coding agents, not human dashboard use.

## Not Guaranteed

Habitat does not guarantee that:

- an AI agent will follow generated guidance
- risky commands are blocked
- all secret-bearing files are detected
- every package manager or runtime edge case is modeled
- every generated policy entry is complete for every ecosystem
- JSON fields remain stable during `v0.x`
- non-macOS environments behave the same way

## Not Implemented

- GUI
- MCP server
- OS-level sandboxing
- command execution or approval
- automatic install/update/repair
- broad global machine inventory
- deep Homebrew inspection
- organization policy management
- redaction modes

## Output Limits

`agent_context.md` is intentionally short. It should prioritize information that changes the agent's next command. More detail belongs in `command_policy.md`, `environment_report.md`, or `scan_result.json`.

`command_policy.md` can be longer, but it is still advisory.

## Secret Handling

Habitat should detect the presence of common secret-bearing files without reading their values.

Tests contain dummy secret-like values and private-key markers to prove non-emission behavior. They are not real credentials.

## Prompt-Injection Handling

Project-derived strings are treated as untrusted. Habitat should prefer normalized signals over raw project prose and should not include arbitrary project file contents in AI-facing Markdown.
