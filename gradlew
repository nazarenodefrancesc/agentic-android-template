#!/usr/bin/env sh
# Self-bootstrapping entrypoint. Once scripts/bootstrap-gradle.sh generates the
# official wrapper JAR/scripts, Gradle may replace this file with its standard wrapper script.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
JAR="$ROOT/gradle/wrapper/gradle-wrapper.jar"
if [ -f "$JAR" ]; then
  exec java -classpath "$JAR" org.gradle.wrapper.GradleWrapperMain "$@"
fi
exec "$ROOT/scripts/bootstrap-gradle.sh" "$@"
