# Agent Context

## Use
- Use pnpm (`pnpm`) because `pnpm-lock.yaml` is present.

## Prefer
- Prefer `pnpm test` when the project defines a test script.
- Prefer `pnpm build` when the project defines a build script.

## Ask First
- Ask before `pnpm install`.
- Ask before `npm install` because `package-lock.json` is also present.
- Ask before modifying lockfiles.
- Ask before `corepack enable`, `corepack prepare`, or package-manager activation that may change shims, fetched package-manager versions, or project metadata.

## Do Not
- Do not silently switch to npm.
- Do not run global package installs.
- Do not execute remote scripts through `curl` or `wget` piped into a shell.

## Notes
- Scanned at: example timestamp
- Project: example Node project with mixed lockfiles
- Read order: this file first; `command_policy.md` before risky commands; `environment_report.md` only for diagnostics.
- Scope: short working context; full approval detail is in `command_policy.md`.
- Mismatch: Multiple JavaScript package-manager signals are present; verify the intended workflow before dependency changes.
- This example is representative, not a stable golden fixture.
