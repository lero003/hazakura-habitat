# Examples

These examples show the shape of Habitat output.

They are not exhaustive fixtures and should not be treated as a stable golden test suite. The generated wording may evolve during `v0.x`.

The purpose is to make the product value visible:

> short, conservative, project-derived context that changes an AI coding agent's next command choice.

## Available Examples

- `swift-package/agent_context.md`: representative output for a simple SwiftPM package.
- `swift-package/command_policy.md`: representative advisory policy for a simple SwiftPM package.
- `swift-package/environment_report.md`: representative audit/debug output for a simple SwiftPM package.
- `swift-package/scan_result.json`: compact representative machine-readable scan shape.
- `node-pnpm-conflict/agent_context.md`: representative output for conflicting JavaScript lockfiles.
- `python-uv-missing-tool/agent_context.md`: representative output when `uv.lock` is present but `uv` is missing.
- `cargo-version-check-failure/agent_context.md`: representative output when Cargo is present but `cargo --version` fails.
- `secret-bearing-files/agent_context.md`: representative output when secret-bearing file signals are present.
- `secret-bearing-files/command_policy.md`: representative policy shape with secret-bearing search/export guidance near the top.
- `behavior-evaluation/habitat-self-use-swiftpm.json`: sanitized observed behavior fixture for SwiftPM self-use.
- `behavior-evaluation/swiftpm-self-use-002.json`: sanitized observed behavior fixture for policy review before SwiftPM self-use Git mutation.
- `behavior-evaluation/swiftpm-self-use-003.json`: sanitized observed behavior fixture for clean SwiftPM dependency-resolution restraint.
- `behavior-evaluation/swiftpm-self-use-004.json`: sanitized observed behavior fixture for current-cycle self-use policy review before Git mutation.
- `behavior-evaluation/swiftpm-self-use-005.json`: sanitized observed behavior fixture for `agent_context.md`-only SwiftPM command selection.
- `behavior-evaluation/swiftpm-self-use-006.json`: sanitized observed behavior fixture for clean SwiftPM validation plus Git policy review.
- `behavior-evaluation/swiftpm-self-use-007.json`: sanitized observed behavior fixture for sandbox-aware SwiftPM verification retry.
- `behavior-evaluation/secret-bearing-search-001.json`: sanitized observed behavior fixture for secret-aware search command shaping.
- `behavior-evaluation/secret-bearing-search-002.json`: sanitized observed behavior fixture for policy review before complex secret-aware search.
- `behavior-evaluation/secret-bearing-search-003.json`: sanitized observed behavior fixture for concrete Git-tracked search exclusions.
- `behavior-evaluation/secret-bearing-search-004.json`: sanitized observed behavior fixture for using the `git grep` pathspec exclusion example.
- `behavior-evaluation/secret-bearing-search-005.json`: sanitized observed behavior fixture proving secret-bearing guidance preserves targeted read-only inspection.
- `behavior-evaluation/secret-bearing-search-006.json`: sanitized observed behavior fixture for avoiding archive/export behavior during secret-aware search.
- `behavior-evaluation/secret-bearing-search-007.json`: sanitized observed behavior fixture proving clean projects keep ordinary read-only search.
- `behavior-evaluation/secret-bearing-search-008.json`: sanitized observed behavior fixture proving dense secret-bearing projects keep targeted source inspection.
- `behavior-evaluation/secret-bearing-search-009.json`: sanitized observed behavior fixture for policy-context over-constraining of targeted source inspection.
- `behavior-evaluation/secret-bearing-search-010.json`: sanitized observed behavior fixture for clarified policy preserving direct non-secret source inspection.
