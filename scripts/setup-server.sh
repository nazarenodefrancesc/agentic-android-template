#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "== Java =="
java -version
MAJOR=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}' | awk -F. '{print ($1==1?$2:$1)}')
if [[ -z "$MAJOR" || "$MAJOR" -lt 17 ]]; then
  echo "ERROR: JDK 17+ is required." >&2
  exit 2
fi

echo "== Gradle wrapper =="
./gradlew --version

echo "== Android tooling =="
if command -v android >/dev/null 2>&1; then
  echo "Android CLI detected: $(command -v android)"
else
  echo "Android CLI not found (optional but recommended for agent-first workflows)."
fi

if [[ -z "${ANDROID_HOME:-${ANDROID_SDK_ROOT:-}}" ]]; then
  echo "WARNING: ANDROID_HOME/ANDROID_SDK_ROOT is not set. Install/configure Android SDK before building."
else
  SDK="${ANDROID_HOME:-$ANDROID_SDK_ROOT}"
  echo "SDK: $SDK"
  for p in "platforms/android-37" "build-tools/36.0.0"; do
    [[ -e "$SDK/$p" ]] || echo "MISSING SDK PACKAGE/PATH: $p"
  done
fi

echo "== Repository check =="
./scripts/repo-check.sh

echo "Server bootstrap checks complete. Run ./scripts/check.sh once Android SDK/dependencies are available."
