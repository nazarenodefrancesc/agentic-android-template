#!/usr/bin/env bash
set -euo pipefail
APK="${1:?Usage: $0 path/to/app.apk}"
[[ -f "$APK" ]] || { echo "ERROR: APK not found: $APK" >&2; exit 2; }

find_apksigner() {
  if command -v apksigner >/dev/null 2>&1; then
    command -v apksigner
    return
  fi
  local sdk="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-}}"
  if [[ -n "$sdk" && -d "$sdk/build-tools" ]]; then
    find "$sdk/build-tools" -maxdepth 2 -type f -name apksigner -perm -u+x 2>/dev/null | sort -V | tail -n1
  fi
}

APKSIGNER="$(find_apksigner || true)"
[[ -n "$APKSIGNER" ]] || {
  echo "ERROR: apksigner not found. Install Android SDK Build-Tools before packaging QA artifacts." >&2
  exit 2
}

OUTPUT="$($APKSIGNER verify --verbose --print-certs "$APK")"
printf '%s\n' "$OUTPUT"
CERT_SHA256="$(printf '%s\n' "$OUTPUT" | sed -n 's/^Signer #1 certificate SHA-256 digest: //p' | head -n1)"
[[ -n "$CERT_SHA256" ]] || { echo "ERROR: could not read signer certificate SHA-256 digest." >&2; exit 1; }
printf 'signing_cert_sha256=%s\n' "$CERT_SHA256"
