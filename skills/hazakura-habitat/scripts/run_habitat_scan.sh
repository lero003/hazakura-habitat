#!/usr/bin/env bash
set -euo pipefail

PROJECT="${1:-.}"
OUTPUT="${2:-}"

PROJECT_ABS="$(cd "$PROJECT" && pwd -P)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd -P)"

find_binary() {
  if [[ -n "${HABITAT_SCAN:-}" && -x "$HABITAT_SCAN" ]]; then
    printf '%s\n' "$HABITAT_SCAN"
    return 0
  fi

  if [[ -f "$PROJECT_ABS/Package.swift" && -f "$PROJECT_ABS/Sources/habitat-scan/main.swift" ]]; then
    if [[ -x "$PROJECT_ABS/.build/debug/habitat-scan" ]]; then
      printf '%s\n' "$PROJECT_ABS/.build/debug/habitat-scan"
      return 0
    fi

    if swift build --package-path "$PROJECT_ABS" >/dev/null; then
      printf '%s\n' "$PROJECT_ABS/.build/debug/habitat-scan"
      return 0
    fi

    return 1
  fi

  if command -v habitat-scan >/dev/null 2>&1; then
    command -v habitat-scan
    return 0
  fi

  for candidate in \
    "$PROJECT_ABS/.build/debug/habitat-scan" \
    "$REPO_ROOT/.build/debug/habitat-scan" \
    "$PROJECT_ABS/dist/habitat-scan" \
    "$REPO_ROOT/dist/habitat-scan"; do
    if [[ -x "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done

  return 1
}

default_output() {
  if git -C "$PROJECT_ABS" check-ignore -q habitat-report/ 2>/dev/null; then
    printf '%s\n' "$PROJECT_ABS/habitat-report"
    return 0
  fi

  local safe_name
  safe_name="$(basename "$PROJECT_ABS" | tr -c 'A-Za-z0-9._-' '_')"
  printf '%s\n' "${TMPDIR:-/tmp}/hazakura-habitat/${safe_name}"
}

BIN="$(find_binary || true)"

if [[ -z "$BIN" ]]; then
  cat >&2 <<'EOF'
hazakura-habitat skill could not find habitat-scan.

Try one of these conservative setup paths:
- Run from a Hazakura Habitat source checkout and build with `swift build`.
- Put a verified `habitat-scan` binary on PATH.
- Set HABITAT_SCAN=/absolute/path/to/habitat-scan.
- Download a GitHub Release asset and verify SHA256SUMS before running it.

Do not use curl|sh or global installs unless the user explicitly authorized them.
EOF
  exit 127
fi

if [[ -z "$OUTPUT" ]]; then
  OUTPUT="$(default_output)"
fi

"$BIN" scan --project "$PROJECT_ABS" --output "$OUTPUT"

cat <<EOF

Hazakura Habitat scan complete.
Output: $OUTPUT

Read first:
- $OUTPUT/agent_context.md

Consult before risky or mutating commands:
- $OUTPUT/command_policy.md
EOF
