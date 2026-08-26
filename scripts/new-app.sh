#!/usr/bin/env bash
set -euo pipefail
if [[ $# -lt 3 ]]; then
  echo "Usage: $0 \"App Name\" com.example.app /path/to/new-project" >&2
  exit 2
fi
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="$1"
PACKAGE="$2"
DEST="$3"

if [[ ! "$PACKAGE" =~ ^[a-zA-Z][a-zA-Z0-9_]*(\.[a-zA-Z][a-zA-Z0-9_]*)+$ ]]; then
  echo "ERROR: invalid Java/Kotlin package: $PACKAGE" >&2; exit 2
fi
if [[ -e "$DEST" ]]; then
  echo "ERROR: destination already exists: $DEST" >&2; exit 2
fi
command -v git >/dev/null 2>&1 || { echo "ERROR: git required." >&2; exit 2; }

TEMPLATE_SHA=$(git -C "$SRC" rev-parse HEAD 2>/dev/null || echo unknown)
mkdir -p "$DEST"
if [[ -n "$(git -C "$SRC" status --porcelain)" ]]; then
  echo "WARNING: template has uncommitted changes; derivation uses committed HEAD $TEMPLATE_SHA" >&2
fi
# Derive only from tracked golden-template state. This naturally excludes build
# output, caches, secrets and the source .git directory without broad path
# patterns that could accidentally remove valid source packages.
git -C "$SRC" archive --format=tar HEAD | tar -C "$DEST" -xf -
mkdir -p "$DEST/dist"
touch "$DEST/dist/.gitkeep"

OLD_PATH="com/example/agentictemplate"
NEW_PATH="${PACKAGE//./\/}"
for base in \
  "$DEST/app/src/main/java" \
  "$DEST/app/src/test/java" \
  "$DEST/app/src/androidTest/java" \
  "$DEST/core/domain/src/main/kotlin" \
  "$DEST/core/domain/src/test/kotlin"; do
  if [[ -d "$base/$OLD_PATH" ]]; then
    mkdir -p "$base/$(dirname "$NEW_PATH")"
    mv "$base/$OLD_PATH" "$base/$NEW_PATH"
    # prune now-empty old package dirs
    find "$base/com/example" -type d -empty -delete 2>/dev/null || true
  fi
done

python3 - "$DEST" "$APP_NAME" "$PACKAGE" <<'PY2'
from pathlib import Path
import sys,re
root=Path(sys.argv[1]); name=sys.argv[2]; pkg=sys.argv[3]
text_ext={'.kt','.kts','.xml','.md','.toml','.properties','.yml','.yaml','.sh','.py','.txt'}
for p in root.rglob('*'):
    if p.is_file() and p.suffix in text_ext and '.git' not in p.parts:
        try: s=p.read_text(encoding='utf-8')
        except UnicodeDecodeError: continue
        s=s.replace('com.example.agentictemplate',pkg)
        s=s.replace('AgenticAndroidTemplate', re.sub(r'[^A-Za-z0-9]','',name) or 'AndroidApp')
        s=s.replace('Agentic Android Template',name)
        s=s.replace('__APP_NAME__',name)
        p.write_text(s,encoding='utf-8')
PY2

# Productize repository state.
cp "$DEST/templates/APP_PRD.md" "$DEST/PRD.md"
cp "$DEST/templates/APP_README.md" "$DEST/README.md"
rm -f "$DEST/TEMPLATE.md"
rm -f "$DEST/docs/decisions/ADR-0001-golden-template-not-common-library.md"
rm -f "$DEST/prd"/T*.md "$DEST/progress"/PROGRESS-T*.md 2>/dev/null || true
find "$DEST/reports" -type f ! -name README.md -delete 2>/dev/null || true
cat > "$DEST/TEMPLATE_ORIGIN.md" <<EOF
# Template origin

- Source: agentic-android-template
- Commit: $TEMPLATE_SHA
- Derived UTC: $(date -u +%Y-%m-%dT%H:%M:%SZ)

This app is an independent snapshot. Template changes do not propagate automatically.
EOF

# Fresh app version baseline.
cat > "$DEST/version.properties" <<EOF
VERSION_NAME=0.1.0
VERSION_CODE=1
EOF

chmod +x "$DEST/gradlew" "$DEST/scripts"/*.sh "$DEST/scripts/task.py"
git -C "$DEST" init -q
git -C "$DEST" add .
git -C "$DEST" -c user.name="Agentic Android Bootstrap" -c user.email="bootstrap@local.invalid" commit -q -m "Bootstrap $APP_NAME from agentic-android-template"

echo "Created: $DEST"
echo "Template commit: $TEMPLATE_SHA"
echo "Next: edit $DEST/PRD.md, create prd/T001.md, then run scripts/setup-server.sh"
