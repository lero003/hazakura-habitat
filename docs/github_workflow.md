# GitHub Workflow

## Repository

GitHub repository:

```text
lero003/hazakura-habitat
```

The local `main` branch tracks `origin/main`.

## Default Development Flow

This project currently uses direct commits to `main`.

That is intentional while the MVP is small and Codex is doing most implementation work.

Use this loop:

```bash
git status
swift test
git add .
git commit -m "Short imperative summary"
git push
```

Create a feature branch only for larger or risky work that should be reviewed before it lands.

## Checks

Run the most relevant local check before committing.

For normal core changes:

```bash
swift test
```

For release packaging changes:

```bash
./scripts/build_release_artifacts.sh
```

## CI

GitHub Actions runs CI on:

- pushes to `main`
- pull requests

CI currently runs:

- `swift --version`
- `swift build`
- `swift test`

## Release Artifacts

The release artifact workflow can be run manually from GitHub Actions.

It also runs when a tag matching `v*` is pushed.

Before pushing a public version tag, prefer a release-candidate check:

1. Run the local release checks:

   ```bash
   swift test
   git diff --check
   ./scripts/build_release_artifacts.sh
   ./dist/habitat-scan --version
   cd dist && shasum -c SHA256SUMS
   ```

2. Run the Release Artifacts workflow manually with `workflow_dispatch`, or use a disposable release-candidate tag if the tagged path itself needs to be exercised.
3. Only after those checks pass, push the public `v*` tag.

If the tag-triggered workflow fails before any GitHub Release is created, fix `main` and restart the tag path. After a GitHub Release is public, keep the tag and assets immutable and use a patch release for material corrections.

Today it packages:

- `dist/habitat-scan`
- `dist/habitat-scan-macos.zip`

The same workflow also uploads generated `.app` and `.dmg` files once the project has a build flow that produces them.

Artifacts are available from:

- the GitHub Actions run
- GitHub Releases for tagged builds

## Local Artifact Build

```bash
./scripts/build_release_artifacts.sh
```

Generated files are written to `dist/`, which is ignored by git.
