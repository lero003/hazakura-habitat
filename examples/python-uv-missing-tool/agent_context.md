# Agent Context

## Use
- `uv.lock` indicates uv is the preferred dependency workflow.

## Prefer
- Prefer read-only project inspection until uv availability is verified.

## Ask First
- Ask before running uv commands because `uv` was not found on PATH.
- Ask before using `pip install`, `pip sync`, or `python -m pip install` as a fallback.
- Ask before creating or recreating virtual environments.

## Do Not
- Do not silently fall back to pip for dependency changes.
- Do not auto-install uv.
- Do not dump environment variables.

## Notes
- Scanned at: example timestamp
- Project: example Python uv project
- Mismatch: Preferred tool appears to be uv, but uv is missing.
- Missing tools are scan data, not fatal scan failures.
