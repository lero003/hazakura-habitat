---
type: nenrin_review
id: review-self-use-trigger-and-report-freshness-2026-05-15
date: 2026-05-15
related_change: self-use-trigger-and-report-freshness
final_judgment: keep
---

# Review: self-use-trigger-and-report-freshness

## Summary

Keep the self-use trigger and report freshness guidance as effective operating guidance.

## Evidence

- A later paired-use review kept stale-report cleanup conditional instead of promoting lifecycle automation without a command mistake.
- Today's ai-mobile intake found a saved report whose key files changed after `Scanned at`, so the run refreshed into temporary output before trusting Gradle or validation guidance.
- The fresh ai-mobile and Nenrin scans reconfirmed existing command guidance, which let the run stop external intake as no-op instead of broadening Habitat scope.
- The evidence supports the current boundary: freshness checks should change trust and scan timing, not become an installer, repair tool, or watched-project workstream.

## Decision

- keep

## Cleanup

- Mark the change reviewed and effective.
- Keep watching only for repeated cases where manual freshness comparison still causes a wrong command or stale release-trust decision.
