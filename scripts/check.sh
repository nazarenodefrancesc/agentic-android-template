#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
./scripts/repo-check.sh
./gradlew --stacktrace :core:domain:test :app:testDebugUnitTest :app:lintQa
