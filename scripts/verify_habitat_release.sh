#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'EOF'
Usage: verify_habitat_release.sh /path/to/release-dir /path/to/project [expected-version]

Verifies a downloaded Habitat release bundle before using its binary:
- SHA256SUMS exists and verifies all downloaded release assets
- SHA256SUMS entries stay inside the release directory
- habitat-scan-macos.zip is extracted into a temporary directory when present
- habitat-scan-macos.zip entries stay inside the extraction directory
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

while IFS= read -r checksum_line || [[ -n "$checksum_line" ]]; do
  [[ -z "$checksum_line" ]] && continue
  if [[ ! "$checksum_line" =~ ^[[:xdigit:]]{64}[[:space:]][\ \*](.+)$ ]]; then
    printf 'error: unsupported SHA256SUMS entry: %s\n' "$checksum_line" >&2
    exit 1
  fi
  checksum_path="${BASH_REMATCH[1]}"
  if [[ -z "$checksum_path" || "$checksum_path" == /* || "$checksum_path" == ".." || "$checksum_path" == ../* || "$checksum_path" == */.. || "$checksum_path" == */../* ]]; then
    printf 'error: SHA256SUMS entry must stay inside release directory: %s\n' "$checksum_path" >&2
    exit 1
  fi
done < "$release_dir/SHA256SUMS"

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
  while IFS= read -r zip_entry || [[ -n "$zip_entry" ]]; do
    [[ -z "$zip_entry" ]] && continue
    if [[ "$zip_entry" == /* || "$zip_entry" == ".." || "$zip_entry" == ../* || "$zip_entry" == */.. || "$zip_entry" == */../* ]]; then
      printf 'error: habitat-scan-macos.zip entry must stay inside extraction directory: %s\n' "$zip_entry" >&2
      exit 1
    fi
  done < <(unzip -Z1 "$release_dir/habitat-scan-macos.zip")
  temp_dir="$(mktemp -d "${TMPDIR:-/tmp}/hazakura-habitat-release.XXXXXX")"
  unzip -q "$release_dir/habitat-scan-macos.zip" -d "$temp_dir"
  release_binary="$temp_dir/dist/habitat-scan"
elif [[ -f "$release_dir/habitat-scan" ]]; then
  release_binary="$release_dir/habitat-scan"
else
  printf 'error: release directory must contain habitat-scan-macos.zip or habitat-scan\n' >&2
  exit 1
fi

if [[ ! -f "$release_binary" || ! -x "$release_binary" ]]; then
  printf 'error: verified release binary is not a regular executable file: %s\n' "$release_binary" >&2
  exit 1
fi

if [[ -L "$release_binary" ]]; then
  printf 'error: verified release binary must not be a symlink: %s\n' "$release_binary" >&2
  exit 1
fi

"$metadata_helper" "$release_binary" "$project_path" "$expected_version"
