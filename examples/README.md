# Examples

These examples show the shape of Habitat output.

They are not exhaustive fixtures and should not be treated as a stable golden test suite. The generated wording may evolve during `v0.x`.

The purpose is to make the product value visible:

> short, conservative, project-derived context that changes an AI coding agent's next command choice.

## Available Examples

- `swift-package/agent_context.md`: representative output for a simple SwiftPM package.
- `swift-package/command_policy.md`: representative advisory policy for a simple SwiftPM package.
- `swift-package/scan_result.json`: compact representative machine-readable scan shape.
- `node-pnpm-conflict/agent_context.md`: representative output for conflicting JavaScript lockfiles.
- `python-uv-missing-tool/agent_context.md`: representative output when `uv.lock` is present but `uv` is missing.
- `secret-bearing-files/agent_context.md`: representative output when secret-bearing file signals are present.
