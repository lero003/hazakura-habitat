# Maintainability Split (2026-05-05)

## Summary

Paid down two roadmap guardrail items from the maintenance section:
1. Extracted `SecretFileDetector` from `Scanner.swift`
2. Split monolithic `HabitatCoreTests.swift` into scenario-grouped suites

## What Changed

### Scanner Extraction
- Moved 20 secret/safety detection functions (~300 lines) from `Scanner.swift` into new `SecretFileDetector.swift`
- `Scanner.swift` reduced from 1850 to 1548 lines
- All call sites updated to use `secretDetector.method(project)` pattern
- Generated output preserved; all 201 tests pass

### Test Suite Split
- `HabitatCoreTests.swift` (8628 lines, 182 tests in one file) → 5 files:
  - `TestHelpers.swift` (133 lines) — shared `FakeCommandRunner`, `makeProject`, assertion helpers
  - `CoreInfrastructureTests.swift` (1133 lines, 28 tests) — argument parser, command runner, skill helper, examples, report writer, markdown, backward compat
  - `BehaviorEvaluationTests.swift` (902 lines, 18 tests) — behavior evaluation fixture tests
  - `SecretFileDetectionTests.swift` (1861 lines, 39 tests) — secret detection, host privacy, unsafe values, symlink safety
  - `PackageAndCommandPolicyTests.swift` (4614 lines, 116 tests) — package manager detection, command policy, runtime mismatch, scan comparison, Xcode/SwiftPM

### Key Decision
- `CoreInfrastructureTests` struct renamed from `HabitatCoreTests` to avoid module-name collision in multi-file test target
- `SecretFileDetector` is a zero-state struct with all methods taking `ProjectInfo` as input
- Helper functions moved from `private` struct methods to module-level functions in `TestHelpers.swift`

## Verification
- `swift test`: 201 tests in 4 suites pass
- No generated output changes
- `swift build` succeeds

## Observation

The test split is coarse — `PackageAndCommandPolicyTests` is still 4614 lines. Future splits could separate scan comparison tests, Xcode/SwiftPM tests, and Python ecosystem tests. The Scanner extraction boundary is clean because secret detection is a narrow domain with clear inputs (`ProjectInfo`) and outputs (`[String]`, `Bool`).

## Follow-up Guidance
- When adding new command families, prefer adding to `PolicyReasonCatalog` (already centralized) rather than to Scanner
- When adding new ecosystem detectors, consider separate files with clear type boundaries
- When `PackageAndCommandPolicyTests` grows beyond ~5000 lines, extract scan comparison tests into their own suite
- Keep `SecretFileDetector` focused on detection and command generation, not policy interpretation
