#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'EOF'
Usage: print_habitat_release_artifact.sh /path/to/release-dir /path/to/project artifact [expected-version]

Verifies a downloaded Habitat release bundle, then prints one generated
artifact to stdout:
- SHA256SUMS exists and verifies all downloaded release assets before any
  downloaded binary is executed
- SHA256SUMS entries stay inside the release directory
- habitat-scan-macos.zip is extracted into a temporary directory when present
- habitat-scan-macos.zip entries stay inside the extraction directory
- otherwise, the standalone habitat-scan asset is used
- binary version, generatorVersion, schemaVersion, and requested artifact
  metadata pass print_habitat_artifact.sh

This script does not install Habitat, mutate shell startup files, or create a
habitat-report directory. Verification output and failures are written to
stderr so stdout remains the requested artifact.
EOF
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  usage
  exit 0
fi

if [[ "$#" -lt 3 || "$#" -gt 4 ]]; then
  usage
  exit 2
fi

release_dir="$1"
project_path="$2"
requested_artifact="$3"
expected_version="${4:-}"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
print_helper="$script_dir/print_habitat_artifact.sh"
checksum_paths=""

if [[ ! -d "$release_dir" ]]; then
  printf 'error: release directory does not exist: %s\n' "$release_dir" >&2
  exit 1
fi

if [[ ! -f "$release_dir/SHA256SUMS" ]]; then
  printf 'error: missing SHA256SUMS in release directory: %s\n' "$release_dir" >&2
  exit 1
fi

if [[ ! -x "$print_helper" ]]; then
  printf 'error: print helper is not executable: %s\n' "$print_helper" >&2
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
  checksum_paths+="${checksum_path}"$'\n'
done < "$release_dir/SHA256SUMS"

checksum_includes_asset() {
  local asset="$1"
  while IFS= read -r checksum_path || [[ -n "$checksum_path" ]]; do
    [[ -z "$checksum_path" ]] && continue
    if [[ "$checksum_path" == "$asset" || "$checksum_path" == "./$asset" ]]; then
      return 0
    fi
  done <<< "$checksum_paths"
  return 1
}

(
  cd "$release_dir"
  shasum -c SHA256SUMS >&2
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
  if ! checksum_includes_asset "habitat-scan-macos.zip"; then
    printf 'error: selected release asset is missing from SHA256SUMS: habitat-scan-macos.zip\n' >&2
    exit 1
  fi
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
  if ! checksum_includes_asset "habitat-scan"; then
    printf 'error: selected release asset is missing from SHA256SUMS: habitat-scan\n' >&2
    exit 1
  fi
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

if [[ -n "$expected_version" ]]; then
  "$print_helper" "$release_binary" "$project_path" "$requested_artifact" "$expected_version"
else
  "$print_helper" "$release_binary" "$project_path" "$requested_artifact"
fi
