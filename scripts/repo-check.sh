#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

required=(
  AGENTS.md LICENSE PRD.md settings.gradle.kts build.gradle.kts gradle/libs.versions.toml
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

  secret_scan_failed=0
  scan_secret_pattern() {
    local category="$1"
    local pattern="$2"
    local matches
    matches=$(git grep -n -I -E "$pattern" -- . 2>/dev/null || true)
    if [[ -n "$matches" ]]; then
      echo "$matches" | awk -F: -v category="$category" '{print "ERROR: possible " category " in " $1 ":" $2}' >&2
      secret_scan_failed=1
    fi
  }

  # Scan tracked text content and print only path/line/category, never the match.
  pem_prefix='-----'
  scan_secret_pattern "PEM private key" "${pem_prefix}BEGIN ([A-Z ]+ )?PRIVATE KEY-----"
  scan_secret_pattern "GitHub token" '\bgh[pousr]_[A-Za-z0-9_]{20,}\b'
  scan_secret_pattern "OpenAI API key" '\bsk-[A-Za-z0-9]{20,}\b'
  scan_secret_pattern "AWS access key ID" '\bAKIA[0-9A-Z]{16}\b'
  scan_secret_pattern "Telegram bot token" '\b[0-9]{8,10}:[A-Za-z0-9_-]{35}\b'
  scan_secret_pattern "Google service-account private key" '"private_key"[[:space:]]*:[[:space:]]*"-----'"BEGIN"

  generic_matches=$(git grep -n -I -E '(^|[^A-Za-z])(password|passwd|secret|api[_-]?key|access[_-]?token)[[:space:]]*[:=][[:space:]]*["'"'"']?[A-Za-z0-9/+_=-]{16,}["'"'"']?' -- . 2>/dev/null || true)
  if [[ -n "$generic_matches" ]]; then
    while IFS= read -r match; do
      line=${match#*:}
      line=${line#*:}
      shopt -s nocasematch
      if [[ "$line" == *'${'* || "$line" == *'$'* || "$line" == *'...'* || "$line" == *example* || "$line" == *changeme* || "$line" == *placeholder* || "$line" == *env.* || "$line" == *os.environ* ]]; then
        shopt -u nocasematch
        continue
      fi
      shopt -u nocasematch
      echo "$match" | awk -F: '{print "ERROR: possible generic credential assignment in " $1 ":" $2}' >&2
      secret_scan_failed=1
    done <<< "$generic_matches"
  fi

  if command -v gitleaks >/dev/null 2>&1; then
    if ! gitleaks detect --source . --no-banner --redact; then
      echo "ERROR: gitleaks detected possible secret material." >&2
      secret_scan_failed=1
    fi
  else
    echo "INFO: gitleaks not installed; built-in tracked-content scan is the mandatory baseline."
  fi
  if [[ "$secret_scan_failed" -ne 0 ]]; then
    exit 1
  fi
fi

echo "Repository structural checks: PASS"
