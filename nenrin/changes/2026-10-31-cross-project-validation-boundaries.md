---
type: nenrin_change
id: cross-project-validation-boundaries
date: 2026-10-31
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/ProjectDetector.swift
  - Sources/HabitatCore/DocumentedValidationCommandEvidence.swift
  - Tests/HabitatCoreTests/InstructionAlignmentPolicyTests.swift
  - Tests/HabitatCoreTests/OperationalGuidanceTests.swift
  - Tests/HabitatCoreTests/PackageScriptValidationPurposeTests.swift
  - Tests/HabitatCoreTests/ScanExecutionInfrastructureTests.swift
  - examples/behavior-evaluation/cross-project-app-validation-boundaries-001.json
review_after:
  tasks: 3
  days: 7
---

# Change: cross-project-validation-boundaries

## Evidence And Decision

Read-only repository inspection and fresh temporary scans covered nine local
projects. Source pointers below identify repository files at intake time;
they are not claims about current distribution or device acceptance.

| Source | Observed decision gap | Habitat carry-back |
| --- | --- | --- |
| neko-no-sanpomichi: `package.json:30`, `AGENTS.md:34-37`, `scripts/testflight.mjs:294-330` | The TestFlight helper publishes and the Store helpers prepare distribution, but their claims were ordinary validation. | Declared delivery namespaces use existing `release_artifact` purpose; normal preferred test/build/check commands stay separate. |
| hazakura-editor: `AGENTS.md:91-108`, `docs/development-automation.md:131-149` | npm and Cargo checks deliberately cover different areas, but the context asserted instruction disagreement. | Describe multiple workflows as scope uncertainty; retain primary tool guidance. |
| 14nichi-note: `AGENTS.md:30-38`, `Package.swift:12-37`, `README.md:25-43` | Documented Swift package core tests were treated as conflicting with the selected Xcode app workflow. | A direct root manifest supports companion package validation; app scheme selection and device acceptance remain separate. |
| hazakura-editor: `AGENTS.md:147`, `docs/handoff.md:8-20` | Canonical automation instructions and a later handoff changed next-step evidence without appearing in observed-file freshness. | Watch the fixed automation and handoff paths; extract claims only from bounded automation inputs. |

Fresh scans of kizashi, hazakura-ai-mobile, mac_desktop_pet,
hazakura-llm-manager, utsushi, and hazakura-vectorizer were also inspected.
Their results did not justify an additional feature in this slice. In
particular, the Android validation/device/environment helpers and the SwiftPM
launch-smoke distinction already worked. hazakura-note resolves to the same
editor checkout and is not counted as another project.

## Expected Behavior

- Agents keep delivery helpers outside ordinary validation. Names are purpose
  hints, not proof of script side effects or authorization to publish.
- Companion checks remain visible without claiming that a core test proves an
  app build, GUI behavior, or physical-device acceptance.
- Handoff changes can invalidate saved context without promoting historical
  handoff commands into current validation instructions.
- Package script identifiers stay short and safe for generated Markdown;
  malformed identifiers and direct or parent instruction symlinks are excluded.

## Verification

- `swift test`: 384 tests in 36 suites passed. `git diff --check` passed.
- `scripts/check_habitat_metadata.sh .build/debug/habitat-scan . 1.1.1`:
  binary/generator version, preview schema, and core artifact checks passed.
- Focused regression suites cover script purpose, complementary validation,
  automation aliases, instruction symlinks, and observed-file metadata.
- Temporary scans confirm all five observed TestFlight/Store helpers are release
  claims; the editor now observes its October 30 handoff and scopes mixed checks;
  the SwiftPM/Xcode app keeps scheme discovery with companion-package guidance.
- Existing ZIP rejection tests now use a relative in-archive executable target.
  This reaches Habitat's symlink guard on current macOS unzip and still verifies
  that the target binary never ran.

## Deferred Scope

- Large editor current documents exceed the existing 64 KiB content limit.
  Their mtimes are observed; do not expand content reading without a new gap.
- Neutral or opaque delivery aliases require project inspection. Do not infer
  their behavior by evaluating package bodies or executing helpers.
- App Review, rights, simulator/device acceptance, model quality, power use,
  and GUI/IME correctness need project-owned evidence, not new Habitat domains.
- Publishing and release artifact refresh are outside this intake. Earlier
  packaged candidates must be rebuilt and verified from the intended source.

## Review After

Review after three related tasks or seven days. Keep these changes only if they
change command scope or stale-report decisions without adding noisy claims.
Watch especially for over-broad delivery namespace matches and workflow hints
that agents incorrectly treat as complete app verification.

## Result

Unjudged beyond local regression checks and read-only rescans.
