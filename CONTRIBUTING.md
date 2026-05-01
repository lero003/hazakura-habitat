# Contributing

Hazakura Habitat is a developer-preview project focused on short, conservative context for AI coding agents.

Contributions are welcome, especially when they improve output quality, explainability, tests, documentation, or the project-local signals that change an agent's next command choice.

## Scope Test

Before proposing a feature, ask:

> Will this change the AI coding agent's next command choice?

If the answer is no, the idea may still be useful, but it probably belongs outside the current roadmap.

## Preferred Contributions

- README, docs, examples, and release-note clarity.
- Output contract hardening for `agent_context.md`, `command_policy.md`, and `scan_result.json`.
- Tests that prove generated output stays short, conservative, and free of secret values.
- Policy reasons for existing ecosystems.
- Fixes for misleading, overbroad, or unsafe guidance.

## Please Avoid For Now

- GUI work.
- MCP server work.
- Command execution, approval, blocking, or sandboxing.
- Automatic install, update, or repair flows.
- Broad global machine inventory.
- Secret value reading, even with redaction.
- Large new ecosystem areas that do not affect command choice.

## Safety And Privacy

Do not paste real secrets, tokens, private keys, private repository names, or sensitive local paths into issues, pull requests, logs, or generated artifacts.

Tests may use dummy secret-like strings to prove non-emission behavior. Mark them clearly as dummy values.

## Development

Run the test suite before opening a pull request:

```bash
swift test
```

For release artifact checks:

```bash
./scripts/build_release_artifacts.sh
cd dist
shasum -c SHA256SUMS
```
