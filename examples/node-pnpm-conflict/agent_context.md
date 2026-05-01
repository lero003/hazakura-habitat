# Agent Context

## Freshness
- Scanned at: example timestamp
- Project: example Node project with mixed lockfiles

## Use
- Use pnpm (`pnpm`) because `pnpm-lock.yaml` is present.
- Prefer `pnpm test` when the project defines a test script.
- Prefer `pnpm build` when the project defines a build script.

## Avoid
- Do not silently switch to npm.
- Do not run global package installs.
- Do not execute remote scripts through `curl` or `wget` piped into a shell.

## Ask First
- Ask before `pnpm install`.
- Ask before `npm install` because `package-lock.json` is also present.
- Ask before modifying lockfiles.
- Ask before `corepack enable`, `corepack prepare`, or package-manager shim changes.

## Mismatches
- Multiple JavaScript package-manager signals are present; verify the intended workflow before dependency changes.

## Notes
- This example is representative, not a stable golden fixture.
