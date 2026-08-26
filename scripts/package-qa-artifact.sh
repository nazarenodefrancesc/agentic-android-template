#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
mkdir -p dist

APK=$(find app/build/outputs/apk/qa -maxdepth 1 -type f -name '*.apk' | head -n 1 || true)
[[ -n "$APK" ]] || { echo "ERROR: QA APK not found." >&2; exit 1; }

APP_NAME=$(grep -oP '(?<=<string name="app_name">).*?(?=</string>)' app/src/main/res/values/strings.xml | head -n1 | tr '[:upper:] ' '[:lower:]-' | tr -cd 'a-z0-9._-' || true)
[[ -n "$APP_NAME" ]] || APP_NAME="android-app"
SHA=$(git rev-parse --short=12 HEAD 2>/dev/null || echo unknown)
STATE=clean
[[ -z "$(git status --porcelain 2>/dev/null || true)" ]] || STATE=dirty
BUILD_NUMBER="${BUILD_NUMBER:-unknown}"
VERSION=$(awk -F= '$1=="VERSION_NAME"{print $2}' version.properties)
OUT="dist/${APP_NAME}-${VERSION}-qa-${BUILD_NUMBER}-${SHA}.apk"
cp "$APK" "$OUT"
sha256sum "$OUT" > "$OUT.sha256"
SIGNING_MODE="debug-fallback"
[[ -f qa-signing.properties ]] && SIGNING_MODE="persistent-qa"
cat > "$OUT.metadata.txt" <<EOF
artifact=$(basename "$OUT")
version=$VERSION
build_number=$BUILD_NUMBER
git_sha=$SHA
git_state=$STATE
built_utc=$(date -u +%Y-%m-%dT%H:%M:%SZ)
signing_mode=$SIGNING_MODE
device_tests=${RUN_DEVICE_TESTS:-0}
EOF

echo "QA artifact: $OUT"
cat "$OUT.metadata.txt"
