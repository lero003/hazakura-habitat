---
type: nenrin_observation
id: cross-project-stale-report-purpose-drift-001
date: 2026-05-15
related_changes:
  - cross-project-stale-report-fixture
  - cross-project-device-install-blocker-fixture
impact_judgment: effective
success_tags:
  - stale_report_downgraded
  - validation_purpose_drift_checked
  - watched_project_kept_read_only
failure_tags: []
---

# Observation: cross-project-stale-report-purpose-drift-001

## Task

Post-v0.7 Habitat loop with read-only ai-mobile and Nenrin intake.

## Observed Behavior

- The saved ai-mobile report was stale after later README and automation guidance changed.
- The saved report still treated `./scripts/device-test.sh` as ordinary local validation, while a fresh temporary scan recorded it as `device_verification` and kept it out of ordinary `Prefer`.
- The watched projects stayed read-only; the carry-back was limited to strengthening the existing stale-report behavior fixture and test.

## Success Signals Observed

- Stale saved reports were treated as bounded uncertainty before trusting validation-purpose metadata.
- Fresh scan confirmed no new scanner behavior was needed.
- The behavior fixture now records validation-purpose drift as a stale-report risk.

## Failure Signals Observed

- None observed in this slice.

## Impact Judgment

effective

## Next Action

- Add generated freshness wording only if agents still miss command-changing validation-purpose drift after this fixture.
