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
  missing=0
  for p in "platforms/android-37" "build-tools/36.0.0" "platform-tools"; do
    if [[ ! -e "$SDK/$p" ]]; then
      echo "MISSING SDK PACKAGE/PATH: $p"
      missing=1
    fi
  done
  APKSIGNER="$SDK/build-tools/36.0.0/apksigner"
  [[ -x "$APKSIGNER" ]] || { echo "MISSING TOOL: apksigner"; missing=1; }
  [[ -x "$SDK/platform-tools/adb" ]] || { echo "MISSING TOOL: adb"; missing=1; }
  if [[ "$missing" == "1" ]]; then
    echo "WARNING: Android SDK is incomplete; QA/device gates will not run until the missing packages are installed."
  fi
fi

echo "== Repository check =="
./scripts/repo-check.sh

echo "Server bootstrap checks complete. Run ./scripts/check.sh once Android SDK/dependencies are available."
