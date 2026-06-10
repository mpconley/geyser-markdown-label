#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$ROOT_DIR/package-src"
DIST_DIR="$ROOT_DIR/dist"
OUTPUT="$DIST_DIR/geyser-markdown.mpackage"

if [[ ! -d "$SRC_DIR" ]]; then
  echo "Missing package source directory: $SRC_DIR" >&2
  exit 1
fi

rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"

pushd "$SRC_DIR" >/dev/null
zip -r "$OUTPUT" . >/dev/null
popd >/dev/null

echo "Built: $OUTPUT"
