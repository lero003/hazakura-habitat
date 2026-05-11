---
type: nenrin_change
id: venv-python-symlink-guidance
date: 2026-05-12
status: observing
impact: unknown
related_files:
  - Sources/HabitatCore/ProjectDetector.swift
  - Tests/HabitatCoreTests/PythonPackagePolicyTests.swift
  - docs/current_status.md
  - docs/roadmap.md
review_after:
  tasks: 3
  days: 7
---

# Change: venv-python-symlink-guidance

## Changed

- Ignored normal .venv/bin/python interpreter symlinks when building project symlink warnings, while preserving real symlinked project metadata safeguards.

## Reason

A fresh scan of hazakura-nenrin recommended .venv/bin/python but also asked before following project symlinks because virtualenv uses interpreter symlinks, creating an over-constrained Python workflow.

## Expected Behavior

- Python projects with normal virtualenv interpreter symlinks should keep .venv/bin/python guidance without symlink metadata warnings; real symlinked metadata or .venv directory links should still require review.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- Fresh scans of Python projects with normal virtualenv interpreter symlinks keep direct `.venv/bin/python` validation guidance without adding symlink-review Ask First noise.
- Future symlink safety work still blocks linked package metadata, runtime hint files, package-auth directories, and `.venv` directory links.

## Failure Signals

- Agents over-ask before ordinary virtualenv Python commands because `.venv/bin/python` is treated as untrusted project metadata.
- The exception grows broad enough to hide symlinked metadata or credential-bearing directory risks.

## Result

Unjudged.
