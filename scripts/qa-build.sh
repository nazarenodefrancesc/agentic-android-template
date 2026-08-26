#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

export BUILD_NUMBER="${BUILD_NUMBER:-$(date +%s)}"

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
