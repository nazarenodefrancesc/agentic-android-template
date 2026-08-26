#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

export BUILD_NUMBER="${BUILD_NUMBER:-$(date +%s)}"

if [[ "${ALLOW_DIRTY_QA:-0}" != "1" ]] && [[ -n "$(git status --porcelain 2>/dev/null || true)" ]]; then
  echo "ERROR: refusing to create a human-testable QA artifact from a dirty Git tree." >&2
  echo "Commit/stash changes first, or set ALLOW_DIRTY_QA=1 for an explicitly non-traceable local build." >&2
  git status --short >&2 || true
  exit 2
fi

if [[ "${SKIP_CHECK:-0}" != "1" ]]; then
  ./scripts/check.sh
fi
if [[ "${RUN_DEVICE_TESTS:-0}" == "1" ]]; then
  ./scripts/device-check.sh
fi

./gradlew --stacktrace :app:assembleQa
ARTIFACT=$(./scripts/package-qa-artifact.sh | tee /dev/stderr | awk -F': ' '/^QA artifact:/ {print $2}' | tail -n1)
if [[ "${PUBLISH_TELEGRAM:-0}" == "1" ]]; then
  ./scripts/publish-telegram.sh "$ARTIFACT"
fi
