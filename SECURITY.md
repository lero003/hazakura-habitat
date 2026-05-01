# Security Policy

Hazakura Habitat is a developer-preview CLI that generates advisory context for AI coding agents.

It is not a sandbox, permission system, runtime security monitor, or command enforcement tool.

## Supported Versions

`v0.x` releases are developer previews. Security fixes will target the latest published preview unless a release note says otherwise.

## Reporting Security Issues

Please do not open public issues that include secrets, tokens, private keys, private repository names, or sensitive local paths.

For now, report sensitive security issues privately through GitHub's private vulnerability reporting if it is enabled for the repository. If private reporting is not available, open a minimal public issue that says a private security report is needed, without including sensitive details.

## Security Model

Habitat is designed to be conservative and read-only during scanning.

It should:

- avoid reading secret values
- detect secret-bearing file presence by path/name when useful
- avoid shell history, clipboard, browser data, and mail data
- avoid running project build, test, install, or script commands during scan
- treat project-derived strings as untrusted data in AI-facing Markdown
- produce advisory command context, not enforce command execution

## Not In Scope

The following are outside the current preview scope:

- OS-level command blocking
- sandboxing
- automatic command approval
- automatic environment repair
- full local security auditing
- organization-wide policy management
- guarantees that an AI agent will follow generated guidance

## Dummy Secret-Like Test Data

Tests intentionally include dummy secret-like strings and private-key markers to verify that generated artifacts do not emit secret values.

These strings are not real credentials.
