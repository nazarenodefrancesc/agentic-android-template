#!/usr/bin/env bash
set -euo pipefail
if ! command -v android >/dev/null 2>&1; then
  echo "ERROR: Android CLI is not installed or not on PATH." >&2
  exit 2
fi
android skills add --all "$@"
