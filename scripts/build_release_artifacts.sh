#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"

rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"

cd "$ROOT_DIR"

if [[ -f "Package.swift" ]]; then
  swift build -c release

  BINARY_PATH="$(find .build -type f -perm -111 -name 'habitat-scan' | head -n 1 || true)"
  if [[ -n "$BINARY_PATH" ]]; then
    cp "$BINARY_PATH" "$DIST_DIR/habitat-scan"
    ditto -c -k --sequesterRsrc --keepParent "$DIST_DIR/habitat-scan" "$DIST_DIR/habitat-scan-macos.zip"
  fi
fi

find "$ROOT_DIR" \( -name "*.app" -o -name "*.dmg" \) -not -path "$DIST_DIR/*" -maxdepth 4 -exec cp -R {} "$DIST_DIR/" \;

if [[ -z "$(find "$DIST_DIR" -mindepth 1 -maxdepth 1 -print -quit)" ]]; then
  echo "No distributable artifacts were produced." >&2
  exit 1
fi

echo "Artifacts written to $DIST_DIR"

