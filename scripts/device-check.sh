#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
DEVICE_TASK="${DEVICE_TASK:-ciApi30AtdQaAndroidTest}"
./gradlew --stacktrace "$DEVICE_TASK" -Pandroid.testoptions.manageddevices.emulator.gpu=swiftshader_indirect
