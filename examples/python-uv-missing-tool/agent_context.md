# Agent Context

## Freshness
- Scanned at: example timestamp
- Project: example Python uv project

## Use
- `uv.lock` indicates uv is the preferred dependency workflow.
- Prefer read-only project inspection until uv availability is verified.

## Avoid
- Do not silently fall back to pip for dependency changes.
- Do not auto-install uv.
- Do not dump environment variables.

## Ask First
- Ask before running uv commands because `uv` was not found on PATH.
- Ask before using `pip install`, `pip sync`, or `python -m pip install` as a fallback.
- Ask before creating or recreating virtual environments.

## Mismatches
- Preferred tool appears to be uv, but uv is missing.

## Notes
- Missing tools are scan data, not fatal scan failures.
