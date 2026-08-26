#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="9.5.0"
BOOT="${AGENTIC_GRADLE_BOOTSTRAP_CACHE:-${XDG_CACHE_HOME:-$HOME/.cache}/agentic-android-template/gradle-${VERSION}}"
ZIP="$BOOT/gradle-${VERSION}-bin.zip"
HOME_DIR="$BOOT/gradle-${VERSION}"
URL="https://services.gradle.org/distributions/gradle-${VERSION}-bin.zip"
TMP="$BOOT/wrapper-project"
mkdir -p "$BOOT"

if [[ ! -x "$HOME_DIR/bin/gradle" ]]; then
  echo "Gradle wrapper JAR is absent; bootstrapping Gradle $VERSION..."
  if [[ ! -f "$ZIP" ]]; then
    if command -v curl >/dev/null 2>&1; then
      curl -fL --retry 3 --retry-delay 2 "$URL" -o "$ZIP"
    elif command -v wget >/dev/null 2>&1; then
      wget -O "$ZIP" "$URL"
    else
      echo "ERROR: curl or wget is required for first bootstrap." >&2
      exit 2
    fi
  fi
  command -v unzip >/dev/null 2>&1 || { echo "ERROR: unzip is required." >&2; exit 2; }
  rm -rf "$HOME_DIR"
  unzip -q "$ZIP" -d "$BOOT"
fi

# Generate only the official wrapper JAR in a tiny Gradle-only project. The
# repository intentionally keeps its small self-bootstrapping launcher, so a
# first bootstrap does not dirty tracked gradlew/gradlew.bat files.
rm -rf "$TMP"
mkdir -p "$TMP"
printf 'rootProject.name = "wrapper-bootstrap"\n' > "$TMP/settings.gradle"
printf '' > "$TMP/build.gradle"
"$HOME_DIR/bin/gradle" -p "$TMP" wrapper --gradle-version "$VERSION" --distribution-type bin
mkdir -p "$ROOT/gradle/wrapper"
cp "$TMP/gradle/wrapper/gradle-wrapper.jar" "$ROOT/gradle/wrapper/gradle-wrapper.jar"
exec "$ROOT/gradlew" "$@"
