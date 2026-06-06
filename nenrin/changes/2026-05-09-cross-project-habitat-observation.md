---
type: nenrin_change
id: cross-project-habitat-observation
date: 2026-05-09
status: observing
impact: unknown
related_files:
  - docs/development_loop.md
  - docs/current_status.md
  - /Users/keisetsu/.codex/automations/hazakura-habitat-1/automation.toml
review_after:
  tasks: 3
  days: 7
---

# Change: cross-project-habitat-observation

## Changed

- Added a cross-project observation boundary to `docs/development_loop.md`.
- Recorded the first `hazakura-ai-mobile` report as a weak but useful observation input in `docs/current_status.md`.
- Kept the boundary explicit: watch command-changing repository facts, not raw reports, project plans, or routine work logs.

## Reason

The user started Android-first app development in `hazakura-ai-mobile` and asked Habitat to watch whether that real use produces lessons for development. The current report detects only `AGENTS.md` and `README.md`, has no primary package-manager signal, and keeps the next move on read-only inspection. That is useful as a starting observation, but not enough to justify broad Android or Gradle scanner work yet.

## Expected Behavior

- Future automation can watch the mobile project's `habitat-report/` without taking over the mobile workstream.
- A later Gradle, Kotlin, Android build, validation-command, or stale-report signal can become one narrow Habitat improvement if it changes the next command.
- Nenrin records only the decision impact of cross-project observation, not copied scan output.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- A later automation run distinguishes weak read-only guidance from command-changing Android project facts.
- Cross-project observation feeds one bounded Habitat doc, test, fixture, or generated-output improvement when evidence appears.
- Nenrin remains a pruning ledger rather than a second copy of watched reports.

## Failure Signals

- Habitat automation starts doing routine Android app work instead of observing command-decision signals.
- Raw `habitat-report/` contents or local project paths are copied into Nenrin as durable records.
- Android ecosystem coverage is expanded before a real command-choice gap appears.

## Result

Unjudged.

## Observations

- 2026-05-09: A later `hazakura-ai-mobile` check found the initial weak signal was now incomplete: the project has `gradlew`, `settings.gradle.kts`, Kotlin build files, and documented Gradle smoke checks, but a fresh Habitat scan still emitted no primary package-manager or validation guidance. This changes the Habitat follow-up from generic stale-report concern to a narrow Gradle project-fact or validation-command gap, while keeping Android ecosystem coverage out of scope.
- 2026-05-09: The user called out the broader pattern that project state changes over time. Docs now say to treat `Scanned at` as command-decision evidence: if key facts changed after the report timestamp, downgrade guidance to bounded stale-context uncertainty and regenerate before trusting package-manager or validation guidance.
- 2026-05-11: Comparing current `hazakura-ai-mobile` and `hazakura-nenrin` usage showed an automation-rule gap rather than a new scanner feature. The mobile saved report was stale after later docs/status edits but a temporary fresh scan still selected Gradle wrapper commands; Nenrin had no project-local Habitat report, and a temporary scan selected `.venv/bin/python` while warning about project symlinks. Habitat automation should do this read-only intake before choosing a slice, carry back only command-changing signals, and otherwise continue with the best local Habitat work or no-op.
- 2026-05-16: The user added `hazakura-llm-manager` as another Habitat usage
  source. A read-only temporary scan found a SwiftPM macOS app with no saved
  `habitat-report/`, and the short context agreed with project guidance to use
  `swift test` / `swift build`. Treat this as a usage-observation source for
  temporary-output adoption, saved-report absence, and SwiftPM sandbox-fallback
  wording, not as permission to take over LLM manager app work.
- 2026-06-06: The user asked to fold heavy `hazakura-note` / `hazakura editor`
  usage into the daily observation loop. A fresh scan of that Tauri app selected
  npm and safe package scripts, but also surfaced `Open uncertainty` because the
  app's current automation docs require a mixed npm + Cargo verification gate
  for code changes. Treat this as useful validation-flow disagreement intake
  and a saved-report freshness source, while keeping the watched app read-only.
  Do not add a fixture or validation taxonomy from this single observation
  unless later runs show repeated command-choice drift.
