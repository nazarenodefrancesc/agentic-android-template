#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if [[ ! -f TEMPLATE.md ]]; then
  echo "Template self-test: SKIP (derived app, TEMPLATE.md absent)"
  exit 0
fi

TMP_ROOT="$(mktemp -d)"
trap 'rm -rf "$TMP_ROOT"' EXIT
DEST="$TMP_ROOT/smoke-app"

./scripts/new-app.sh "Template Smoke App" com.example.templatesmoke "$DEST" >/dev/null

[[ -d "$DEST/.git" ]] || { echo "ERROR: derived repository has no .git" >&2; exit 1; }
[[ ! -e "$DEST/TEMPLATE.md" ]] || { echo "ERROR: TEMPLATE.md leaked into derived app" >&2; exit 1; }
[[ -e "$DEST/TEMPLATE_ORIGIN.md" ]] || { echo "ERROR: TEMPLATE_ORIGIN.md missing" >&2; exit 1; }
[[ -e "$DEST/LICENSE" ]] || { echo "ERROR: inherited LICENSE missing from derived app" >&2; exit 1; }
grep -q 'Template Smoke App' "$DEST/PRD.md"
grep -q 'com.example.templatesmoke' "$DEST/app/build.gradle.kts"
grep -q 'application code may be licensed separately' "$DEST/TEMPLATE_ORIGIN.md"
if grep -R --exclude-dir=.git --exclude='TEMPLATE_ORIGIN.md' -n 'com\.example\.agentictemplate' "$DEST" >/dev/null; then
  echo "ERROR: stale template package remained after derivation" >&2
  exit 1
fi

cat > "$DEST/prd/T001.md" <<'TASK1'
---
id: T001
title: First smoke task
status: PLANNED
priority: P0
depends_on: []
human_acceptance: not_required
---
# T001
TASK1
cat > "$DEST/prd/T002.md" <<'TASK2'
---
id: T002
title: Dependent smoke task
status: PLANNED
priority: P0
depends_on: [T001]
human_acceptance: not_required
---
# T002
TASK2

python3 "$DEST/scripts/task.py" validate >/dev/null
[[ "$(python3 "$DEST/scripts/task.py" next | cut -f1)" == "T001" ]]
python3 "$DEST/scripts/task.py" set T001 IN_PROGRESS >/dev/null
python3 "$DEST/scripts/task.py" set T001 IN_REVIEW >/dev/null
python3 "$DEST/scripts/task.py" set T001 COMPLETE >/dev/null
[[ "$(python3 "$DEST/scripts/task.py" next | cut -f1)" == "T002" ]]

# Validate cycle detection on an intentionally invalid temporary task graph.
cat > "$DEST/prd/T003.md" <<'TASK3'
---
id: T003
title: Cycle A
status: PLANNED
priority: P1
depends_on: [T004]
human_acceptance: not_required
---
# T003
TASK3
cat > "$DEST/prd/T004.md" <<'TASK4'
---
id: T004
title: Cycle B
status: PLANNED
priority: P1
depends_on: [T003]
human_acceptance: not_required
---
# T004
TASK4
if python3 "$DEST/scripts/task.py" validate >/dev/null 2>&1; then
  echo "ERROR: dependency cycle was not detected" >&2
  exit 1
fi

# Human acceptance must block COMPLETE until an accepted artifact is recorded.
rm -f "$DEST/prd/T003.md" "$DEST/prd/T004.md"
cat > "$DEST/prd/T005.md" <<'TASK5'
---
id: T005
title: Physical acceptance smoke
status: PLANNED
priority: P1
depends_on: []
human_acceptance: required
---
# T005
TASK5
python3 "$DEST/scripts/task.py" set T005 IN_PROGRESS >/dev/null
python3 "$DEST/scripts/task.py" set T005 IN_REVIEW >/dev/null
if python3 "$DEST/scripts/task.py" set T005 COMPLETE >/dev/null 2>&1; then
  echo "ERROR: task completed without required human acceptance" >&2
  exit 1
fi
printf 'fake-apk-for-task-cli-test' > "$DEST/dist/fake.apk"
sha256sum "$DEST/dist/fake.apk" > "$DEST/dist/fake.apk.sha256"
cat > "$DEST/dist/fake.apk.metadata.txt" <<'META'
artifact=fake.apk
version=0.1.0
build_number=123
git_sha=deadbeef
git_state=clean
signing_mode=persistent-qa
signing_cert_sha256=001122
fast_gates=pass
device_tests=not_run
META
python3 "$DEST/scripts/task.py" accept T005 dist/fake.apk >/dev/null
python3 "$DEST/scripts/task.py" set T005 COMPLETE >/dev/null
[[ -f "$DEST/reports/acceptance/T005.md" ]]

git -C "$DEST" fsck --no-progress >/dev/null

echo "Template derivation + task lifecycle self-test: PASS"
