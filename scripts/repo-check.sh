#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

required=(
  AGENTS.md PRD.md settings.gradle.kts build.gradle.kts gradle/libs.versions.toml
  app/build.gradle.kts core/domain/build.gradle.kts
  scripts/task.py scripts/check.sh scripts/qa-build.sh scripts/verify-apk.sh scripts/template-self-test.sh scripts/publish-telegram.sh templates/APP_PRD.md
)
for f in "${required[@]}"; do
  [[ -e "$f" ]] || { echo "MISSING: $f" >&2; exit 1; }
done

for s in scripts/*.sh gradlew; do
  bash -n "$s"
done
python3 -m py_compile scripts/task.py
python3 scripts/task.py validate

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  if git ls-files | grep -E '(^|/)(qa-signing\.properties|.*\.(jks|keystore)|local\.properties)$' >/dev/null; then
    echo "ERROR: signing/local secret-like file is tracked by Git." >&2
    exit 1
  fi
  if git ls-files | grep -E '(^|/)(__pycache__/|.*\.py[co]$)' >/dev/null; then
    echo "ERROR: generated Python cache is tracked by Git." >&2
    exit 1
  fi
fi

echo "Repository structural checks: PASS"
