#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'EOF'
Usage: verify_habitat_release.sh /path/to/release-dir /path/to/project [expected-version]

Verifies a downloaded Habitat release bundle before using its binary:
- SHA256SUMS exists and verifies all downloaded release assets
- habitat-scan-macos.zip is extracted into a temporary directory when present
- otherwise, the standalone habitat-scan asset is used
- binary version, scan_result.json generatorVersion, schemaVersion, generated
  artifact metadata, and core stdout artifacts pass check_habitat_metadata.sh

This script does not install Habitat, mutate shell startup files, or create a
habitat-report directory.
EOF
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  usage
  exit 0
fi

if [[ "$#" -lt 2 || "$#" -gt 3 ]]; then
  usage
  exit 2
fi

release_dir="$1"
project_path="$2"
expected_version="${3:-}"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
metadata_helper="$script_dir/check_habitat_metadata.sh"

if [[ ! -d "$release_dir" ]]; then
  printf 'error: release directory does not exist: %s\n' "$release_dir" >&2
  exit 1
fi

if [[ ! -f "$release_dir/SHA256SUMS" ]]; then
  printf 'error: missing SHA256SUMS in release directory: %s\n' "$release_dir" >&2
  exit 1
fi

if [[ ! -x "$metadata_helper" ]]; then
  printf 'error: metadata helper is not executable: %s\n' "$metadata_helper" >&2
  exit 1
fi

(
  cd "$release_dir"
  shasum -c SHA256SUMS
)

release_binary=""
temp_dir=""
cleanup() {
  if [[ -n "$temp_dir" && -d "$temp_dir" ]]; then
    rm -rf "$temp_dir"
  fi
}
trap cleanup EXIT

if [[ -f "$release_dir/habitat-scan-macos.zip" ]]; then
  if ! command -v unzip >/dev/null 2>&1; then
    printf 'error: unzip is required to verify habitat-scan-macos.zip\n' >&2
    exit 1
  fi
  temp_dir="$(mktemp -d "${TMPDIR:-/tmp}/hazakura-habitat-release.XXXXXX")"
  unzip -q "$release_dir/habitat-scan-macos.zip" -d "$temp_dir"
  release_binary="$temp_dir/dist/habitat-scan"
elif [[ -f "$release_dir/habitat-scan" ]]; then
  release_binary="$release_dir/habitat-scan"
else
  printf 'error: release directory must contain habitat-scan-macos.zip or habitat-scan\n' >&2
  exit 1
fi

if [[ ! -x "$release_binary" ]]; then
  printf 'error: verified release binary is not executable: %s\n' "$release_binary" >&2
  exit 1
fi

"$metadata_helper" "$release_binary" "$project_path" "$expected_version"
