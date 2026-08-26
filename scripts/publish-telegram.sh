#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

: "${TELEGRAM_BOT_TOKEN:?Set TELEGRAM_BOT_TOKEN in the server secret environment}"
: "${TELEGRAM_CHAT_ID:?Set TELEGRAM_CHAT_ID in the server secret environment}"

APK="${1:-$(find dist -maxdepth 1 -type f -name '*.apk' -printf '%T@ %p\n' | sort -nr | head -n1 | cut -d' ' -f2-)}"
[[ -n "$APK" && -f "$APK" ]] || { echo "ERROR: QA APK not found." >&2; exit 1; }
META="$APK.metadata.txt"
CAPTION="QA build ready"
if [[ -f "$META" ]]; then
  VERSION=$(awk -F= '$1=="version"{print $2}' "$META")
  BUILD=$(awk -F= '$1=="build_number"{print $2}' "$META")
  SHA=$(awk -F= '$1=="git_sha"{print $2}' "$META")
  STATE=$(awk -F= '$1=="git_state"{print $2}' "$META")
  SIGNING=$(awk -F= '$1=="signing_mode"{print $2}' "$META")
  DEVICES=$(awk -F= '$1=="device_tests"{print $2}' "$META")
  CAPTION="QA ${VERSION} | build ${BUILD} | git ${SHA} (${STATE}) | signing ${SIGNING} | device-tests ${DEVICES}"
fi

curl -fS \
  -F "chat_id=$TELEGRAM_CHAT_ID" \
  -F "caption=$CAPTION" \
  -F "document=@$APK;type=application/vnd.android.package-archive" \
  "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendDocument" >/dev/null

echo "Published to Telegram: $APK"
