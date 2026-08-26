#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
mkdir -p dist

APK=$(find app/build/outputs/apk/qa -maxdepth 1 -type f -name '*.apk' | sort | head -n1 || true)
[[ -n "$APK" ]] || { echo "ERROR: QA APK not found." >&2; exit 1; }

APP_NAME=$(python3 - <<'PY'
import re
from pathlib import Path
s=Path('app/src/main/res/values/strings.xml').read_text(encoding='utf-8')
m=re.search(r'<string\s+name=["\']app_name["\']>(.*?)</string>', s, re.S)
name=(m.group(1) if m else 'android-app').strip().lower().replace(' ','-')
print(''.join(c for c in name if c.isalnum() or c in '._-') or 'android-app')
PY
)
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
VERIFY_OUTPUT="$(./scripts/verify-apk.sh "$OUT")"
CERT_SHA256="$(printf '%s\n' "$VERIFY_OUTPUT" | awk -F= '$1=="signing_cert_sha256"{print $2}' | tail -n1)"
[[ -n "$CERT_SHA256" ]] || { echo "ERROR: signer fingerprint missing after APK verification." >&2; exit 1; }
cat > "$OUT.metadata.txt" <<EOF2
artifact=$(basename "$OUT")
version=$VERSION
build_number=$BUILD_NUMBER
git_sha=$SHA
git_state=$STATE
built_utc=$(date -u +%Y-%m-%dT%H:%M:%SZ)
signing_mode=$SIGNING_MODE
signing_cert_sha256=$CERT_SHA256
fast_gates=$([[ "${SKIP_CHECK:-0}" == "1" ]] && echo skipped || echo pass)
device_tests=$([[ "${RUN_DEVICE_TESTS:-0}" == "1" ]] && echo pass || echo not_run)
EOF2

echo "QA artifact: $OUT"
cat "$OUT.metadata.txt"
